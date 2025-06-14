import 'dart:convert';
import 'dart:typed_data';
import 'package:mime/mime.dart';

class Base64Utils {
  static Uint8List? decodeImageFromBase64(String? base64String) {
    if (base64String == null || base64String.trim().isEmpty) return null;

    try {
      final base64Str =
          base64String.contains(',')
              ? base64String.split(',').last
              : base64String;

      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  static String encodeImageToDataUri(Uint8List bytes) {
    final mimeType =
        lookupMimeType('', headerBytes: bytes) ?? 'application/octet-stream';
    final base64Str = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64Str';
  }
}
