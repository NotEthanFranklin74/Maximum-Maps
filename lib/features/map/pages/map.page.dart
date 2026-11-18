import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maximum_maps/core/location/location.service.dart';
import 'package:maximum_maps/core/map/map_style.service.dart';
import 'package:maximum_maps/core/map/models/map.style.dart';
import 'package:maximum_maps/features/map/services/map_controller.service.dart';
import 'package:maximum_maps/features/map/widgets/map_controls.widget.dart';
import 'package:maximum_maps/features/map/widgets/map_style.selector.dart';
import 'package:maximum_maps/features/places/models/place.model.dart';
import 'package:maximum_maps/features/places/widgets/place_details.widget.dart';
import 'package:maximum_maps/features/search/models/search_result.model.dart';
import 'package:maximum_maps/features/search/services/search.service.dart';

class MapPage extends StatefulWidget {
  const MapPage({ super.key });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapControllerService _mapService = MapControllerService();
  final LocationService _locationService = LocationService();
  final MapStyleService _mapStyleService = MapStyleService();
  final SearchService _searchService = SearchService();

  MapLibreMapController? _mapController;
  MapStyle _currentStyle = MapStyle.light;

  bool _locationPermissionGranted = false;
  bool _isGettingLocation = false;
  bool _isFollowingLocation = false;
  bool _isLoadingStyle = true;
  bool _isSearching = false;

  static const LatLng initialLocation = LatLng(
    51.5072, 
    -0.1276
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  void dispose() {
    _mapService.dispose();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    _mapService.initialise(controller);

    _goToMyLocation();
    _startLiveLocation();
  }

  Future<void> _loadMapStyle() async {
    final style = await _mapStyleService.getSavedStyle();

    if (!mounted) return;

    setState(() {
      _currentStyle = style;
      _isLoadingStyle = false;
    });
  }

  Future<void> _changeMapStyle(MapStyle style) async {
    if (style == _currentStyle) return;

    setState(() {
      _currentStyle = style;
    });

    await _mapStyleService.saveStyle(style);

    await _mapController?.setStyle(style.url);
  }

  Future<void> _goToMyLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      final position = await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _locationPermissionGranted = true;
      });

      await _mapService.moveTo(
        LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 16
      );
    } catch (err) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        )
      );
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _startLiveLocation() async {
    try {
      final enabled = await _locationService.isLocationEnabled();

      if (!enabled) {
        throw Exception("Please enable location services on your device");
      }

      final permission = await _locationService.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission was denied");
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Location permission is permenantly denied. "
          "Please enable it in your device settings. ",
        );
      }

      if (!mounted) return;

      if (_mapController == null) {
        throw Exception("Map not finished loading yet");
      }

      setState(() {
        _locationPermissionGranted = true;
      });

      await _mapController!.updateMyLocationTrackingMode(
        MyLocationTrackingMode.tracking,
      );

      setState(() {
        _isFollowingLocation = true;
      });
    } catch (err) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchService.searchLocations(query);

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No locations found'),
          ),
        );
        return;
      }

      _showSearchResults(results);
    } catch (err) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $err'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _onMapTap(Point<double> point, LatLng coordinates) async {
    if (_mapController == null) return;

    try {
      final features = await _mapController!.queryRenderedFeatures(point, [], null);

      if (features.isEmpty) {
        return;
      }

      Map<String, dynamic> currentFeature = {};
      num currentScore = 0;

      for (final feature in features) {
        var score = 0;

        if (feature["geometry"]["type"] != null && feature["geometry"]["type"] == "Point") {
          score += 10;
        }

        if (feature["properties"]["name"] != null) {
          score += 10;
        }

        if (feature["properties"]["class"] != null) {
          score += 10;
        }

        if (feature["properties"]["rank"] != null) {
          score += 10;
        }

        if (score > currentScore && score >= 20) {
          currentScore = score;
          currentFeature = feature;
        }
      }

      if (currentFeature == {} || currentScore == 0) {
        return;
      }

      final correctedFeature = {
        "id": currentFeature["id"].toString(),
        "name": currentFeature["properties"]["name"],
        "category": currentFeature["properties"]["class"],
        "subcategory": currentFeature["properties"]["subclass"],
        "latitude": currentFeature["geometry"]["coordinates"].elementAt(1),
        "longitude": currentFeature["geometry"]["coordinates"].elementAt(0),
      };

      final place = Place.fromJson(correctedFeature);

      _showPlaceDetails(place);
    } catch (err) {
      debugPrint("Could not find any features: $err");
    }
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return PlaceDetailsWidget(
              place: place,
              scrollController: scrollController,
              onDirections: () {
                Navigator.pop(context);
              },
              onSave: () {
                
              },
            );
          },
        );
      },
    );
  }

  void _showSearchResults(List<SearchResult> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContent) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Search results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];

                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(result.name),
                      subtitle: Text(
                        result.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(sheetContent);

                        _mapService.moveTo(
                          LatLng(
                            result.latitude, 
                            result.longitude
                          ),
                          zoom: 16,
                        );
                      },
                    );
                  },
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStyle) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            initialCameraPosition: const CameraPosition(
              target: initialLocation,
              zoom: 13,
            ),
            styleString: _currentStyle.url,

            onMapCreated: _onMapCreated,

            myLocationEnabled: _locationPermissionGranted,

            myLocationTrackingMode: MyLocationTrackingMode.none,

            myLocationRenderMode: MyLocationRenderMode.normal,

            onCameraTrackingChanged: (mode) {
              if (!mounted) return;

              setState(() {
                _isFollowingLocation = mode != MyLocationTrackingMode.none;
              });
            },

            onMapClick: _onMapTap,

            onCameraTrackingDismissed: () {
              if (!mounted) return;

              setState(() {
                _isFollowingLocation = false;
              });
            },

            onStyleLoadedCallback: () {
              debugPrint("Map style loaded");
            },

            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: _searchLocations,
                decoration: InputDecoration(
                  hintText: "Search places and addresses",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MapStyleSelector(
                  selectedStyle: _currentStyle,
                  onChanged: _changeMapStyle
                ),

                const SizedBox(height: 16),
                
                MapControls(
                  onZoomIn: _mapService.zoomIn,
                  onZoomOut: _mapService.zoomOut,
                  onMyLocation: _goToMyLocation,
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}