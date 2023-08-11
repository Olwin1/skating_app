import 'dart:typed_data';

class BaseFileModel {
  final String key;
  final String type;
  final Uint8List object;
  final String? jsonObject;

  BaseFileModel({
    required this.key,
    required this.object,
    required this.type,
    this.jsonObject,
  });
}
