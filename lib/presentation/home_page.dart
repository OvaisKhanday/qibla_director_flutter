import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' show degrees, radians;

import '../logic/location_service.dart';
import '../logic/qibla_angle.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool permissionGranted = false;
  String permissionMessage = "";

  double qiblaAngle = 0;
  double compassAngle = 0;

  LocationService locationService = LocationService();
  late LocationData locationData;

  void _getLocationAngle() {
    locationService.getCurrentLocation().then((location) {
      locationData = location;
      qiblaAngle = QiblaDirection.calculateQiblaDirection(locationData.latitude!, locationData.longitude!);
      setState(() {
        permissionGranted = true;
      });
    }).catchError((onError) {
      setState(() {
        permissionGranted = false;
        permissionMessage = onError.message.toString();
      });
    });
  }

  @override
  void initState() {
    _getLocationAngle();

    magnetometerEvents.listen((event) {
      double angleInDegrees = degrees(atan2(event.y, event.x)).roundToDouble();
      // if angle is between [-1 to -180] it will change that to [359 to 180]
      if (angleInDegrees < 0) angleInDegrees += 360;
      //! delete this line in production
      // print('compass angle is ::::::::::::::::::::::::::::::::: ' + angleInDegrees.toString());
      setState(() {
        compassAngle = angleInDegrees;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // builds++;
    // print('-------------------------------------' + builds.toString());
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Qibla Director'))),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            qiblaWidget(),
            const Spacer(),
            const Text(
              '"Put the phone on a flat surface and away from any magnetic field"\nThis is still in beta version',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Designed and Developed with ❤️ by Khanday Ovais'),
            const SizedBox(height: 24)
          ],
        ));
  }

  Center qiblaWidget() {
    return Center(
        child: !permissionGranted
            ? Text(permissionMessage)
            : Transform.rotate(
                angle: radians(qiblaAngle - compassAngle + 90),
                child: Image.asset(
                  'assets/qibla_image.png',
                  width: 200,
                  height: 200,
                )));
  }
}
