abstract class IFileManager {
  Future<bool> writeUserRequestDataWithTime(
      String key, String type, String model, Duration time);
  Future<String?> getUserRequestDataOnString(String key, String type);
  Future<bool> removeUserRequestSingleCache(String key, String type);
  Future<bool> removeUserRequestCache(String? type);
}
