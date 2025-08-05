export "upload_avatar_stub.dart"
    if (dart.library.io) "upload_avatar_android.dart"
    if (dart.library.html) "upload_avatar_web.dart";
