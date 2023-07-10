// Import the Geolocator package
import 'package:geolocator/geolocator.dart';

// Export the function 'hasLocationPermission' from the 'check_permission.dart' file
export 'package:patinka/fitness_tracker/check_permission.dart'
    show hasLocationPermission;

// Define a function that returns a Future of boolean value indicating whether the app has location permission
Future<bool> hasLocationPermission() async {
  // Declare variables to store information about whether location services are enabled and the user's location permission
  bool serviceEnabled;
  LocationPermission permission;

  // Check whether location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // If location services are disabled, return an error Future with a message indicating that location services are disabled
    return Future.error('Location services are disabled.');
  }

  // Check the user's location permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // If the user has denied location permission, request permission
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // If the user denies the permission again, return an error Future with a message indicating that location permissions are denied
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // If the user has permanently denied location permission, return an error Future with a message indicating that location permissions are permanently denied
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // If location services are enabled and the user has granted location permission, return a Future with a boolean value of true
  return true;
}
