import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> _requestService({int limit = 20}) async {
    for (var i = 0; i < limit; i++) {
      try {
        return await location.serviceEnabled();
      } catch (e) {
        // do nothing
      }
    }
    return false;
  }

  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await _requestService();
    if (!serviceEnabled) {
      if (await location.requestService() == false) {
        throw Exception('GPS service not enabled');
      }
    }

    final permissionGranted = await location.requestPermission();
    if (permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever) {
      throw Exception("Location Permission not granted");
    }

    return await location.getLocation();
  }
}
