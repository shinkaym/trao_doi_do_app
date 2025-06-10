import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  /// Chuyển đổi XFile thành Base64 string an toàn
  static Future<String?> xFileToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytesToBase64(bytes, file.path);
    } catch (e) {
      debugPrint('Error converting XFile to Base64: $e');
      return null;
    }
  }

  /// Chuyển đổi Uint8List thành Base64 string với MIME type tự động
  static String? bytesToBase64(Uint8List bytes, [String? filePath]) {
    try {
      // Detect MIME type based on file extension or magic bytes
      final mimeType = _detectMimeType(bytes, filePath);
      final base64String = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error converting bytes to Base64: $e');
      return null;
    }
  }

  /// Giải mã Base64 string thành Uint8List
  static Uint8List? base64ToBytes(String base64String) {
    try {
      // Remove data URL prefix if exists
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      // Validate base64 string
      if (!_isValidBase64(cleanBase64)) {
        debugPrint('Invalid Base64 string');
        return null;
      }

      return base64Decode(cleanBase64);
    } catch (e) {
      debugPrint('Error decoding Base64: $e');
      return null;
    }
  }

  /// Kiểm tra Base64 string có hợp lệ không
  static bool _isValidBase64(String str) {
    try {
      // Base64 string length must be multiple of 4
      if (str.length % 4 != 0) return false;

      // Check if string contains only valid Base64 characters
      final regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return regex.hasMatch(str);
    } catch (e) {
      return false;
    }
  }

  /// Tự động phát hiện MIME type
  static String _detectMimeType(Uint8List bytes, [String? filePath]) {
    // Check magic bytes first
    if (bytes.length >= 3) {
      // JPEG
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'image/jpeg';
      }
      // PNG
      if (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A) {
        return 'image/png';
      }
      // GIF
      if (bytes.length >= 6 &&
          bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38 &&
          (bytes[4] == 0x37 || bytes[4] == 0x39) &&
          bytes[5] == 0x61) {
        return 'image/gif';
      }
      // WebP
      if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return 'image/webp';
      }
    }

    // Fallback to file extension
    if (filePath != null) {
      final extension = filePath.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        case 'gif':
          return 'image/gif';
        case 'webp':
          return 'image/webp';
        default:
          return 'image/jpeg'; // Default fallback
      }
    }

    return 'image/jpeg'; // Default fallback
  }

  /// Kiểm tra kích thước ảnh
  static bool isValidImageSize(Uint8List bytes, {double maxSizeMB = 5.0}) {
    final sizeInMB = bytes.lengthInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }

  /// Tạo widget hiển thị ảnh từ Base64 an toàn
  static Widget buildImageFromBase64({
    required String base64String,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Widget? loadingWidget,
  }) {
    final bytes = base64ToBytes(base64String);

    if (bytes == null) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
    }

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error displaying image: $error');
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
    );
  }
}
