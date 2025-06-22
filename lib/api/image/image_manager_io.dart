import "dart:io";
import "dart:typed_data";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/caching/manager.dart";

Future<bool> saveBackgroundFile(
    final Uint8List bytes, final String url) async {
  final String filename = url.split("/").last;
  final Directory dir = await getApplicationDocumentsDirectory();
  final String filePath = "/backgrounds/$filename";
  final File file = File(path.join(dir.path, path.basename(filePath)));

  if (await file.exists()) {
    NetworkManager.instance.saveData(
        name: "current-background",
        data: filePath,
        type: CacheTypes.background);
    return true;
  }

  await file.writeAsBytes(bytes);
  NetworkManager.instance.saveData(
      name: "current-background", data: filePath, type: CacheTypes.background);

  return true;
}
