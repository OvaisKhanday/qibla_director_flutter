import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<PermissionStatus> requestPermission() async {
    final permission = await location.requestPermission();
    return permission;
  }

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
    try {
      final serviceEnabled = await _requestService();
      if (!serviceEnabled) {
        if (await location.requestService() == false) {
          throw Exception('GPS service not enabled');
        }
      }
    } catch (e) {
      throw Exception('Error in getting location service');
    }

    final permissionGranted = await requestPermission();
    if (permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever) {
      throw Exception("Location Permission not granted");
    }

    return await location.getLocation();
  }
}
