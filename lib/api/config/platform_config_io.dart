import "dart:io";

String getBaseUri() =>
    Platform.isAndroid ? "http://10.0.2.2:4000" : "http://localhost:4000";
