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
  bool permissionInProcess = true;
  String permissionMessage = "";

  double qiblaAngle = 0;
  double compassAngle = 0;

  LocationService locationService = LocationService();
  late LocationData locationData;

  void _initialize() async {
    try {
      locationData = await locationService.getCurrentLocation();
      qiblaAngle = QiblaDirection.calculateQiblaDirection(locationData.latitude!, locationData.longitude!);
      print('permissionInProcess --- false');
      setState(() {
        permissionGranted = true;
        permissionInProcess = false;
      });
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
    } catch (error) {
      setState(() {
        permissionInProcess = false;
        permissionGranted = false;
        permissionMessage = 'There was an error with location access';
      });
    }
  }

  @override
  void initState() {
    print('init was called --------------->');
    _initialize();
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
            QiblaCompassWidget(
                permissionInProcess: permissionInProcess,
                permissionGranted: permissionGranted,
                permissionMessage: permissionMessage,
                qiblaAngle: qiblaAngle,
                compassAngle: compassAngle),
            const Spacer(),
            const Text(
              '"Put the phone on a flat surface and away from any magnetic field"\nThis is still in beta version',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Designed and Developed with ❤️ by Khanday Ovais',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24)
          ],
        ));
  }
}

class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({
    super.key,
    required this.permissionInProcess,
    required this.permissionGranted,
    required this.permissionMessage,
    required this.qiblaAngle,
    required this.compassAngle,
  });

  final bool permissionInProcess;
  final bool permissionGranted;
  final String permissionMessage;
  final double qiblaAngle;
  final double compassAngle;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: permissionInProcess
            ? const CircularProgressIndicator.adaptive()
            : (!permissionGranted
                ? Text(permissionMessage)
                : Transform.rotate(
                    angle: radians(qiblaAngle - compassAngle + 90),
                    child: Image.asset(
                      'assets/qibla_image.png',
                      width: 200,
                      height: 200,
                    ))));
  }
}
