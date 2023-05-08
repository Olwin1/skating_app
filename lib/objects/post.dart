import 'package:shared_preferences/shared_preferences.dart';

class PostsCache {
  static Future<void> addToCache(List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("posts", value);
  }

  static Future<List<String>?> getFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("posts");
  }
}
