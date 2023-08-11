part of '../local_file.dart';

class _FileManager {
  static _FileManager? _instance;
  _FileManager._init();

  static _FileManager get instance {
    _instance ??= _FileManager._init();
    return _instance!;
  }

  final String fileName = "fireball.json";

  Future<Directory> documentsPath() async {
    String tempPath = (await getApplicationDocumentsDirectory()).path;
    return Directory(tempPath).create();
  }

  Future<String> filePath() async {
    final path = (await documentsPath()).path;
    return "$path/$fileName";
  }

  Future<File> getFile() async {
    String sFilePath = await filePath();
    File userDocumentFile = File(sFilePath);
    return userDocumentFile;
  }

  Future<Map?> fileReadAllData() async {
    try {
      String sFilePath = await filePath();
      File userDocumentFile = File(sFilePath);
      final data = await userDocumentFile.readAsString();
      final jsonData = jsonDecode(data);

      return jsonData;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeLocalModelInFile(String key, BaseLocal local) async {
    String sFilePath = await filePath();
    final sample = local.toJson();
    final Map model = {key: sample};

    final oldData = await fileReadAllData();
    model.addAll(oldData ?? {});
    var newLocalData = jsonEncode(model);

    File userDocumentFile = File(sFilePath);
    return await userDocumentFile.writeAsString(newLocalData,
        flush: true, mode: FileMode.write);
  }

  Future<String?> readOnlyKeyData(String key) async {
    Map? datas = await fileReadAllData();
    if (datas != null && datas[key] != null) {
      final model = datas[key];
      final item = BaseLocal.fromJson(model);
      if (DateTime.now().isBefore(item.time)) {
        return item.model;
      } else {
        await removeSingleItem(key);
        return null;
      }
    }
    return null;
  }

  /// Remove old key in  [Directory].
  Future<bool> removeSingleItem(String key) async {
    Map? tempDirectory = await fileReadAllData();
    String? dkey = tempDirectory!.keys.isNotEmpty
        ? tempDirectory.keys.singleWhere(
            (element) => element == key,
          )
        : null;

    if (dkey != null) {
      tempDirectory.remove(dkey);
      String sFilePath = await filePath();
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
