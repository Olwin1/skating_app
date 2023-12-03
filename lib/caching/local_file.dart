import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import './ifile_manager.dart';
import './models/local_data.dart';

part './core/file.dart';

class LocalFile implements IFileManager {
  final _FileManager _fileManager = _FileManager.instance;

  @override
  Future<String?> getUserRequestDataOnString(String key, String type) {
    return _fileManager.readOnlyKeyData(key, type);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, String type, String model, Duration time) async {
    final localModel = BaseLocal(model: model, time: DateTime.now().add(time));
    await _fileManager.writeLocalModelInFile(key, type, localModel);
    return true;
  }

  @override
  Future<bool> removeUserRequestCache(String? type) async {
    await _fileManager.clearAllDirectoryItems();
    return true;
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key, String type) async {
    await _fileManager.removeSingleItem(key, type);
    return true;
  }
}
