import "dart:convert";

import "package:patinka/caching/ifile_manager.dart";
import "package:patinka/caching/models/local_data.dart";
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

part "file_stub.dart";

class LocalFile implements IFileManager {
  // Replace with an actual cache at some point
  final Map<String, String> _cache = {};

  @override
  Future<String?> getUserRequestDataOnString(
          final String key, final String type) async =>
      _cache["$type-$key"];

  @override
  Future<bool> writeUserRequestDataWithTime(final String key, final String type,
      final String model, final Duration time) async {
    _cache["$type-$key"] = model;
    return true;
  }

  @override
  Future<bool> removeUserRequestCache(final String? type) async {
    _cache.removeWhere(
        (final k, final _) => type == null || k.startsWith("$type-"));
    return true;
  }

  @override
  Future<bool> removeUserRequestSingleCache(
      final String key, final String type) async {
    _cache.remove("$type-$key");
    return true;
  }
}
