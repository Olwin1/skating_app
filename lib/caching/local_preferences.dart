import 'dart:convert';

import './models/local_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './ifile_manager.dart';

part './core/preferences.dart';

class LocalPreferences implements IFileManager {
  LocalManager manager = LocalManager.instance;
  @override
  Future<String?> getUserRequestDataOnString(String key, String type) async {
    return await manager.getModelString(key);
  }

  @override
  Future<bool> removeUserRequestCache(String? type) async {
    return await manager.removeAllLocalData(type);
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key, String type) async {
    return await manager.removeModel(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, String type, Object model, Duration time) async {
    return await manager.writeModelInJson(model, key, time);
  }
}
