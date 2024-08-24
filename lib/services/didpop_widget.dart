// import 'package:flutter/material.dart';

// import 'navigation_service.dart';

// class DidPopWidget<T> extends MaterialPageRoute<T> {
//   DidPopWidget({
//     required super.builder,
//     super.settings,
//   });

//   @override
//   bool didPop(T? result) {
//     print("errors");
//     if (NavigationService.getCurrentIndex() != 0) {
//       // If the current index is not 0, switch to index 0 using pushReplacement
//       NavigationService.navigatorKey("0")?.currentState?.pushReplacementNamed("/");
//       return false; // Prevent the default pop behavior
//     }
//     return super.didPop(result);
//   }
// }
