import 'dart:convert';
import 'dart:typed_data';
import 'dart:math'; // Thêm import này để sử dụng min()
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;

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

  // Hàm chuyển ảnh sang JPG trước khi encode
  static String encodeImageToJpgDataUri(Uint8List bytes, {int quality = 85}) {
    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) throw Exception('Invalid image');

      final jpgBytes = img.encodeJpg(decodedImage, quality: quality);
      return 'data:image/jpeg;base64,${base64Encode(jpgBytes)}';
    } catch (e) {
      // Fallback nếu không convert được
      return encodeImageToDataUri(bytes);
    }
  }

  // Hàm resize ảnh với padding về kích thước mong muốn
  static String encodeImageWithPadding(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    int paddingColor = 0xFFFFFFFF, // Màu trắng
    int quality = 85,
  }) {
    try {
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception('Invalid image');

      // Tạo ảnh mới với kích thước đích
      final paddedImage = img.Image(width: targetWidth, height: targetHeight);

      // Đổ màu nền - sử dụng getColor() cho version 4.5.4
      final whiteColor = paddedImage.getColor(255, 255, 255);
      img.fill(paddedImage, color: whiteColor); // Màu trắng

      // Tính toán tỷ lệ và vị trí đặt ảnh
      final ratio = min(
        targetWidth / originalImage.width,
        targetHeight / originalImage.height,
      );

      final resizedWidth = (originalImage.width * ratio).round();
      final resizedHeight = (originalImage.height * ratio).round();

      final xOffset = (targetWidth - resizedWidth) ~/ 2;
      final yOffset = (targetHeight - resizedHeight) ~/ 2;

      // Resize ảnh gốc
      final resizedImage = img.copyResize(
        originalImage,
        width: resizedWidth,
        height: resizedHeight,
      );

      // Đặt ảnh vào giữa canvas
      img.compositeImage(
        paddedImage,
        resizedImage,
        dstX: xOffset,
        dstY: yOffset,
      );

      // Encode thành JPG
      final jpgBytes = img.encodeJpg(paddedImage, quality: quality);
      return 'data:image/jpeg;base64,${base64Encode(jpgBytes)}';
    } catch (e) {
      // Fallback nếu có lỗi
      return encodeImageToDataUri(bytes);
    }
  }

  // Hàm wrapper cho kích thước 400x400
  static String encodeImageTo400x400WithPadding(Uint8List bytes) {
    return encodeImageWithPadding(bytes, targetWidth: 400, targetHeight: 400);
  }

  // Hàm wrapper cho kích thước 800x600
  static String encodeImageTo800x600WithPadding(Uint8List bytes) {
    return encodeImageWithPadding(bytes, targetWidth: 800, targetHeight: 600);
  }
}
