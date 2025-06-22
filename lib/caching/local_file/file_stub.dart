part of "local_file_stub.dart";




class _FileManager {
  _FileManager._init();
  static _FileManager? _instance;

  static _FileManager get instance {
    _instance ??= _FileManager._init();
    return _instance!;
  }

  Future<Map?> fileReadAllData(final String type) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(type);
    return data != null ? jsonDecode(data) : null;
  }

  Future<String?> readOnlyKeyData(final String key, final String type) async {
    final Map? data = await fileReadAllData(type);
    if (data != null && data[key] != null) {
      final item = BaseLocal.fromJson(data[key]);
      if (DateTime.now().isBefore(item.time)) {
        return item.model;
      } else {
        await removeSingleItem(key, type);
      }
    }
    return null;
  }

  Future<void> writeLocalModelInFile(
      final String key, final String type, final BaseLocal local) async {
    final prefs = await SharedPreferences.getInstance();
    final Map model = {key: local.toJson()};
    final Map? oldData = await fileReadAllData(type);
    model.addAll(oldData ?? {});
    await prefs.setString(type, jsonEncode(model));
  }

  Future<bool> removeSingleItem(final String key, final String type) async {
    final prefs = await SharedPreferences.getInstance();
    final Map? data = await fileReadAllData(type);
    if (data != null && data.containsKey(key)) {
      data.remove(key);
      await prefs.setString(type, jsonEncode(data));
      return true;
    }
    return false;
  }

  Future<void> clearAllDirectoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Ideally, you'd store a list of all keys used in caching
    // For now, assume `prefs.clear()` is acceptable
    await prefs.clear();
  }
}
