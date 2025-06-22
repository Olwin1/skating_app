part of "local_file_io.dart";

class _FileManager {
  _FileManager._init();
  static _FileManager? _instance;

  static _FileManager get instance {
    _instance ??= _FileManager._init();
    return _instance!;
  }

  Future<Directory> documentsPath() async {
    final String tempPath = (await getTemporaryDirectory()).path;
    //String tempPath = (await getExternalStorageDirectory())!.path;
    return Directory(tempPath).create();
  }

  Future<String> filePath(final String type) async {
    final path = (await documentsPath()).path;
    return "$path/$type.json";
  }

  Future<File> getFile(final String type) async {
    final String sFilePath = await filePath(type);
    final File userDocumentFile = File(sFilePath);
    return userDocumentFile;
  }

  Future<Map?> fileReadAllData(final String type) async {
    try {
      final String sFilePath = await filePath(type);
      final File userDocumentFile = File(sFilePath);
      final data = await userDocumentFile.readAsString();
      final jsonData = jsonDecode(data);

      return jsonData;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeLocalModelInFile(
      final String key, final String type, final BaseLocal local) async {
    final String sFilePath = await filePath(type);
    final sample = local.toJson();
    final Map model = {key: sample};

    final oldData = await fileReadAllData(type);
    model.addAll(oldData ?? {});
    final newLocalData = jsonEncode(model);

    final File userDocumentFile = File(sFilePath);
    return userDocumentFile.writeAsString(newLocalData,
        flush: true, mode: FileMode.write);
  }

  Future<String?> readOnlyKeyData(final String key, final String type) async {
    final Map? datas = await fileReadAllData(type);
    if (datas != null && datas[key] != null) {
      final model = datas[key];
      final item = BaseLocal.fromJson(model);
      if (DateTime.now().isBefore(item.time)) {
        return item.model;
      } else {
        await removeSingleItem(key, type);
        return null;
      }
    }
    return null;
  }

  /// Remove old key in  [Directory].
  Future<bool> removeSingleItem(final String key, final String type) async {
    final Map? tempDirectory = await fileReadAllData(type);
    final String? dkey = tempDirectory!.keys.isNotEmpty
        ? tempDirectory.keys.singleWhere(
            (final element) => element == key,
          )
        : null;

    if (dkey != null) {
      tempDirectory.remove(dkey);
      final String sFilePath = await filePath(type);
      final File userDocumentFile = File(sFilePath);
      await userDocumentFile.writeAsString(
        jsonEncode(tempDirectory),
        flush: true,
        mode: FileMode.write,
      );
      return true;
    }
    return false;
  }

  /// Remove old [Directory].
  Future clearAllDirectoryItems() async {
    final Directory tempDirectory = await documentsPath();
    await tempDirectory.delete(recursive: true);
  }
}
