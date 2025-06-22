import "dart:convert";

import "package:patinka/api/config/config.dart";

import "package:patinka/caching/ifile_manager.dart";
import "package:patinka/caching/local_file/local_file_stub.dart"
    if (dart.library.io) "package:patinka/caching/local_file/local_file_io.dart";

import "package:patinka/caching/models/base_model.dart";

class NetworkManager {
  NetworkManager._init() {
    fileManager = LocalFile();
  }
  IFileManager? fileManager;

  static NetworkManager? _instance;
  static NetworkManager get instance {
    _instance ??= NetworkManager._init();
    return _instance!;
  }

  Future<bool> saveData<T extends BaseModel>(
      {required final String name,
      required final CacheTypes type,
      required final dynamic data}) async {
    try {
      fileManager!.writeUserRequestDataWithTime("cached-$name", type.toString(),
          jsonEncode(data), const Duration(hours: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getLocalData(
      {required final String name, required final CacheTypes type}) async {
    if (fileManager != null) {
      final data = await fileManager!
          .getUserRequestDataOnString("cached-$name", type.toString());
      return data;
    }
    return null;
  }

  Future<bool> deleteLocalData(
      {required final String name, required final CacheTypes type}) async {
    try {
      if (fileManager != null) {
        await fileManager!
            .removeUserRequestSingleCache("cached-$name", type.toString());
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
        await fileManager!.removeUserRequestCache(null);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> deleteUserLocalData({required final String targetUser}) async {
    try {
      if (fileManager != null) {
        await deleteLocalData(name: targetUser, type: CacheTypes.user);
        await deleteLocalData(name: "channels", type: CacheTypes.list);
        await deleteLocalData(
            name: "user-posts-$targetUser", type: CacheTypes.list);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
