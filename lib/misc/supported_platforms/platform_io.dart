import "dart:io";

// Windows app and linux is not supported
bool get isUnsupportedPlatform => Platform.isWindows || Platform.isLinux;
bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;
bool get isAndroidPlatform => Platform.isAndroid;
