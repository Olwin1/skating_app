// Import necessary packages and files
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skating_app/swatch.dart';
import 'check_permission.dart';

import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a StatefulWidget for the Speedometer page
class SpeedometerPage extends StatefulWidget {
  const SpeedometerPage({Key? key}) : super(key: key);
  @override
  State<SpeedometerPage> createState() => _SpeedometerPage();
}

// Initialize current speed and start time variables
double currentSpeed = 0;

// Define the State for the Speedometer page
class _SpeedometerPage extends State<SpeedometerPage> {
  // Define a global key for the KdGaugeView widget
  GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();
  StreamSubscription? stream;

  @override
  Widget build(BuildContext context) {
    // Define a gradient for the active gauge color
    ui.Gradient activeGradient = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(550, 7),
      [
        const Color.fromARGB(255, 181, 214, 174),
        const Color.fromARGB(255, 23, 189, 142),
        const Color.fromARGB(255, 255, 50, 50)
      ],
      [0, 0.2, 0.6],
    );

    // Check if location permission is granted and listen to position updates
    try {
      hasLocationPermission().then((value) => {
            stream = Geolocator.getPositionStream().listen((position) {
              key.currentState!.updateSpeed(position.speed,
                  animate: true, duration: const Duration(milliseconds: 800));
            })
          });
    } catch (e) {
      print("Speedometer Error: $e");
    }
    // Return a Scaffold with an AppBar and a KdGaugeView widget
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        centerTitle: false,
        title: Title(
          title: AppLocalizations.of(context)!.speedometer,
          color: const Color(0xFFDDDDDD),
          child: Text(AppLocalizations.of(context)!.speedometer),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage("assets/backgrounds/graffiti.png"),
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.srcOver)),
        ),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        child: KdGaugeView(
          baseGaugeColor: Colors.black87,
          speedTextStyle: TextStyle(
              color: swatch[401], fontSize: 60, fontWeight: FontWeight.bold),
          unitOfMeasurementTextStyle: TextStyle(
              color: swatch[301], fontSize: 30, fontWeight: FontWeight.w600),
          key: key,
          minSpeed: 0,
          maxSpeed: 30,
          speed: 0,
          animate: true,
          unitOfMeasurement: "Km/h",
          fractionDigits: 2,
          activeGaugeColor: swatch[900]!, //Color.fromARGB(255, 197, 213, 26),
          subDivisionCircleColors: const Color.fromARGB(255, 13, 141, 13),
          divisionCircleColors: const Color.fromARGB(255, 13, 141, 13),
          activeGaugeGradientColor: activeGradient,
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("SPEEDOMETER DISPOSE");
    stream?.cancel();
    super.dispose();
  }
}
