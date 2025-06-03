import 'dart:convert';
import 'dart:typed_data';

import 'package:trao_doi_do_app/domain/entities/item.dart';

extension ItemImageDecode on Item {
  Uint8List? get decodedImage {
    if (image == null || image!.isEmpty) return null;
    try {
      final cleanedBase64 =
          image!.contains(',') ? image!.split(',').last : image!;
      return base64Decode(cleanedBase64);
    } catch (e) {
      return null;
    }
  }
}
