import 'dart:typed_data';

class PostImage {
  final String id;
  final Uint8List? imageData;
  final String? imagePath;
  final double sizeInMB;

  const PostImage({
    required this.id,
    this.imageData,
    this.imagePath,
    required this.sizeInMB,
  });

  PostImage copyWith({
    String? id,
    Uint8List? imageData,
    String? imagePath,
    double? sizeInMB,
  }) {
    return PostImage(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      sizeInMB: sizeInMB ?? this.sizeInMB,
    );
  }
}
