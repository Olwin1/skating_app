// Import necessary packages and files
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/swatch.dart';
import '../api/config.dart';
import 'check_permission.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a StatefulWidget for the Speedometer page
class SpeedometerPage extends StatefulWidget {
  const SpeedometerPage({Key? key}) : super(key: key);
  @override
  State<SpeedometerPage> createState() => _SpeedometerPage();
}

// Define the State for the Speedometer page
class _SpeedometerPage extends State<SpeedometerPage> {
  // Define a global key for the KdGaugeView widget
  GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();
  StreamSubscription? stream;

  @override
  Widget build(BuildContext context) {
    // Check if location permission is granted and listen to position updates
    try {
      hasLocationPermission().then((value) => {
            stream = Geolocator.getPositionStream().listen((position) {
              key.currentState?.updateSpeed(position.speed,
                  animate: true, duration: const Duration(milliseconds: 800));
            })
          });
    } catch (e) {
      commonLogger.e("Speedometer Error: $e");
    }
    // Return a Scaffold with an AppBar and a KdGaugeView widget
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 8,
        shadowColor: Colors.green.shade900,
        backgroundColor: Config.appbarColour,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leadingWidth: 48,
        centerTitle: false,
        title: Title(
          title: AppLocalizations.of(context)!.speedometer,
          color: const Color(0xFFDDDDDD),
          child: Text(
            AppLocalizations.of(context)!.speedometer,
            style: TextStyle(color: swatch[701]),
          ),
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
          //baseGaugeColor: Colors.black87,
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
          activeGaugeColor: swatch[401]!, //Color.fromARGB(255, 197, 213, 26),
          subDivisionCircleColors: const Color.fromARGB(255, 13, 141, 13),
          divisionCircleColors: const Color.fromARGB(255, 13, 141, 13),
          inactiveGaugeColor: Colors.lightBlue,
          //activeGaugeGradientColor: activeGradient,
        ),
      ),
    );
  }

  @override
  void dispose() {
    commonLogger.v("Disposing Speedometer");
    stream?.cancel();
    super.dispose();
  }
}
