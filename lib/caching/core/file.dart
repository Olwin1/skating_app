part of '../local_file.dart';

class _FileManager {
  static _FileManager? _instance;
  _FileManager._init();

  static _FileManager get instance {
    _instance ??= _FileManager._init();
    return _instance!;
  }

  Future<Directory> documentsPath() async {
//    String tempPath = (await getTemporaryDirectory()).path;
    String tempPath = (await getExternalStorageDirectory())!.path;
    return Directory(tempPath).create();
  }

  Future<String> filePath(String type) async {
    final path = (await documentsPath()).path;
    return "$path/$type.json";
  }

  Future<File> getFile(String type) async {
    String sFilePath = await filePath(type);
    File userDocumentFile = File(sFilePath);
    return userDocumentFile;
  }

  Future<Map?> fileReadAllData(String type) async {
    try {
      String sFilePath = await filePath(type);
      File userDocumentFile = File(sFilePath);
      final data = await userDocumentFile.readAsString();
      final jsonData = jsonDecode(data);

      return jsonData;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeLocalModelInFile(
      String key, String type, BaseLocal local) async {
    String sFilePath = await filePath(type);
    final sample = local.toJson();
    final Map model = {key: sample};

    final oldData = await fileReadAllData(type);
    model.addAll(oldData ?? {});
    var newLocalData = jsonEncode(model);

    File userDocumentFile = File(sFilePath);
    return await userDocumentFile.writeAsString(newLocalData,
        flush: true, mode: FileMode.write);
  }

  Future<String?> readOnlyKeyData(String key, String type) async {
    Map? datas = await fileReadAllData(type);
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
  Future<bool> removeSingleItem(String key, String type) async {
    Map? tempDirectory = await fileReadAllData(type);
    String? dkey = tempDirectory!.keys.isNotEmpty
        ? tempDirectory.keys.singleWhere(
            (element) => element == key,
          )
        : null;

    if (dkey != null) {
      tempDirectory.remove(dkey);
      String sFilePath = await filePath(type);
      File userDocumentFile = File(sFilePath);
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
    Directory tempDirectory = (await documentsPath());
    await tempDirectory.delete(recursive: true);
  }
}
