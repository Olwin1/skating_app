import "dart:convert";

import "package:patinka/caching/ifile_manager.dart";
import "package:patinka/caching/models/local_data.dart";
import "package:shared_preferences/shared_preferences.dart";

part "./core/preferences.dart";

class LocalPreferences implements IFileManager {
  LocalManager manager = LocalManager.instance;
  @override
  Future<String?> getUserRequestDataOnString(final String key, final String type) async => await manager.getModelString(key);

  @override
  Future<bool> removeUserRequestCache(final String? type) async => await manager.removeAllLocalData(type);

  @override
  Future<bool> removeUserRequestSingleCache(final String key, final String type) async => await manager.removeModel(key);

  @override
  Future<bool> writeUserRequestDataWithTime(
      final String key, final String type, final Object model, final Duration time) async => await manager.writeModelInJson(model, key, time);
}
