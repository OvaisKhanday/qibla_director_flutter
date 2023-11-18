import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<PermissionStatus> requestPermission() async {
    final permission = await location.requestPermission();
    return permission;
  }

  Future<LocationData> getCurrentLocation() async {
    try {
      final serviceEnabled = await location.serviceEnabled();
      await Future.delayed(const Duration(microseconds: 100));
      if (!serviceEnabled) {
        if (await location.requestService() == false) {
          throw Exception('GPS service not enabled');
        }
      }
    } on PlatformException catch (_) {
      throw Exception('Error in getting location service');
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
