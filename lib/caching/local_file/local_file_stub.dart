import "dart:convert";

import "package:patinka/caching/ifile_manager.dart";
import "package:patinka/caching/models/local_data.dart";
import "package:shared_preferences/shared_preferences.dart"
    show SharedPreferences;

part "file_stub.dart";

class LocalFile implements IFileManager {
  final _FileManager _fileManager = _FileManager.instance;

  @override
  Future<String?> getUserRequestDataOnString(
          final String key, final String type) =>
      _fileManager.readOnlyKeyData(key, type);

  @override
  Future<bool> writeUserRequestDataWithTime(final String key, final String type,
      final String model, final Duration time) async {
    final localModel = BaseLocal(model: model, time: DateTime.now().add(time));
    await _fileManager.writeLocalModelInFile(key, type, localModel);
    return true;
  }

  @override
  Future<bool> removeUserRequestCache(final String? type) async {
    await _fileManager.clearAllDirectoryItems();
    return true;
  }

  @override
  Future<bool> removeUserRequestSingleCache(
      final String key, final String type) async {
    await _fileManager.removeSingleItem(key, type);
    return true;
  }
}
