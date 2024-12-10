abstract class IFileManager {
  Future<bool> writeUserRequestDataWithTime(
      final String key, final String type, final String model, final Duration time);
  Future<String?> getUserRequestDataOnString(final String key, final String type);
  Future<bool> removeUserRequestSingleCache(final String key, final String type);
  Future<bool> removeUserRequestCache(final String? type);
}
