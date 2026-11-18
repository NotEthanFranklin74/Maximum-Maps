import 'package:maximum_maps/features/places/models/place.model.dart';

class PlaceService {
  late List<Place> _places;

  List<Place> getAllPlaces() {
    return List.unmodifiable(_places);
  }

  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere(
        (place) => place.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  List<Place> getPlacesByCategory(String category) {
    return _places
      .where((place) => place.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Place> searchPlaces(String query) {
    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isEmpty) return [];

    return _places.where((place) {
      return place.name.toLowerCase().contains(searchQuery) || 
        place.category.toLowerCase().contains(searchQuery) || 
        (place.description?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  void addPlace(Place place) {
    if (_places.any((existing) => existing.id == place.id)) {
      throw ArgumentError("A place with this ID already exists");
    }

    _places.add(place);
  }

  bool removePlace(String id) {
    final index = _places.indexWhere((place) => place.id == id);

    if (index == -1) return false;

    _places.removeAt(index);
    return true;
  }
}