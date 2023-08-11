part of '../local_preferences.dart';

class LocalManager {
  static LocalManager get instance {
    _instance ??= LocalManager._init();

    return _instance!;
  }

  static LocalManager? _instance;
  LocalManager._init();
  SharedPreferences? _preferences;
  Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<bool> writeModelInJson(
      dynamic body, String url, Duration duration) async {
    final pref = await preferences;
    BaseLocal local =
        BaseLocal(model: body, time: DateTime.now().add(duration));
    final json = jsonEncode(local.toJson());
    if (body != null && json.isNotEmpty) {
      return await pref.setString(url, json);
    }
    return false;
  }

  Future<String?> getModelString(String url) async {
    final pref = await preferences;
    final jsonString = pref.getString(url);
    if (jsonString != null) {
      final jsonModel = jsonDecode(jsonString);
      final model = BaseLocal.fromJson(jsonModel);
      if (DateTime.now().isAfter(model.time)) {
        return BaseLocal.fromJson(jsonModel).model;
      } else {
        await removeModel(url);
      }
    }

    return null;
  }

  Future<bool> removeAllLocalData(String url) async {
    final pref = await preferences;
    pref.getKeys().removeWhere((element) => element.contains(url));
    return true;
  }

  Future<bool> removeModel(String url) async {
    final pref = await preferences;
    return await pref.remove(url);
  }
}
