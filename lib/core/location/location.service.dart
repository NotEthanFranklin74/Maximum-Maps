import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<Position> getCurrentLocation() async {
    final enabled = await isLocationEnabled();

    if (!enabled) {
      throw Exception("Location services are disabled");
    }

    final permission = await requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission was denied");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Location services permenantly denied. "
        "Please enable it in your device settings. ",
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    return position;
  }
}