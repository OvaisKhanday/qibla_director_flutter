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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool permissionGranted = false;
  bool permissionInProcess = true;
  String permissionMessage = "";

  double rotationAngle = 360;

  LocationService locationService = LocationService();
  late LocationData locationData;

  void _initialize() async {
    try {
      locationData = await locationService.getCurrentLocation();
      double qiblaAngle = QiblaDirection.calculateQiblaDirection(locationData.latitude!, locationData.longitude!);
      setState(() {
        permissionGranted = true;
        permissionInProcess = false;
      });
      magnetometerEvents.listen((event) {
        double angleInDegrees = degrees(atan2(event.y, event.x));
        if (angleInDegrees < 0) angleInDegrees += 360;

        setState(() {
          rotationAngle = qiblaAngle - angleInDegrees + 90;
        });
      }, onError: (error) {
        throw Exception("Magnetometer Not found on your device");
      });
    } on Exception catch (error) {
      setState(() {
        permissionInProcess = false;
        permissionGranted = false;
        permissionMessage = error.toString();
      });
    } catch (error) {
      setState(() {
        permissionInProcess = false;
        permissionGranted = false;
        permissionMessage = 'There was an error';
      });
    }
  }

  @override
  void initState() {
    _initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: const Center(child: Text('Qibla Director'))),
        body: AnimatedContainer(
      duration: const Duration(seconds: 1),
      color: (rotationAngle > -2 && rotationAngle < 2)
          ? Color.fromARGB(213, 76, 175, 79)
          : Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          QiblaCompassWidget(
              permissionInProcess: permissionInProcess,
              permissionGranted: permissionGranted,
              permissionMessage: permissionMessage,
              rotationAngle: rotationAngle),
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
      ),
    ));
  }
}

class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({
    super.key,
    required this.permissionInProcess,
    required this.permissionGranted,
    required this.permissionMessage,
    required this.rotationAngle,
  });

  final bool permissionInProcess;
  final bool permissionGranted;
  final String permissionMessage;
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: permissionInProcess
            ? const CircularProgressIndicator.adaptive()
            : (!permissionGranted
                ? Text(permissionMessage)
                : Transform.rotate(
                    angle: radians(rotationAngle),
                    child: Image.asset(
                      'assets/qibla_image.png',
                      width: 200,
                      height: 200,
                    ))));
  }
}
