import "dart:async";
import "dart:typed_data";
import "dart:ui" as ui;

class ImageDecoder {
  static Future<ui.Image> decodeImage(final Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }
}
