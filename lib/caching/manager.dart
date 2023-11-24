import 'dart:convert';

import 'package:patinka/api/config.dart';

import './ifile_manager.dart';
import './local_file.dart';
import './models/base_model.dart';

class NetworkManager {
  IFileManager? fileManager;

  static NetworkManager? _instance;
  static NetworkManager get instance {
    _instance ??= NetworkManager._init();
    return _instance!;
  }

  NetworkManager._init() {
    fileManager = LocalFile();
  }

  Future<bool> saveData<T extends BaseModel>(
      {required String name,
      required CacheTypes type,
      required dynamic data}) async {
    try {
      fileManager!.writeUserRequestDataWithTime(
          "cached-$type-$name", jsonEncode(data), const Duration(hours: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getLocalData(
      {required String name, required CacheTypes type}) async {
    if (fileManager != null) {
      final data =
          await fileManager!.getUserRequestDataOnString("cached-$type-$name");
      return data;
    }
    return null;
  }

  Future<bool> deleteLocalData(
      {required String name, required CacheTypes type}) async {
    try {
      if (fileManager != null) {
        await fileManager!.removeUserRequestSingleCache("cached-$type-$name");
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> deleteAllLocalData() async {
    try {
      if (fileManager != null) {
        await fileManager!.removeUserRequestCache("cached");
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
