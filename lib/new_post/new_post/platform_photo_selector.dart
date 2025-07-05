export "photo_selector_stub.dart"
    if (dart.library.io) "photo_selector_mobile.dart"
    if (dart.library.html) "photo_selector_web.dart";
