import 'dart:typed_data';

class GiveAwayItem {
  final String id;
  final String name;
  final String? description;
  final Uint8List? imageData;
  final String? imagePath;
  final int quantity;
  final bool isFromPreset;
  final int? categoryId;

  const GiveAwayItem({
    required this.id,
    required this.name,
    this.description,
    this.imageData,
    this.imagePath,
    this.quantity = 1,
    this.isFromPreset = false,
    this.categoryId,
  });

  GiveAwayItem copyWith({
    String? id,
    String? name,
    String? description,
    Uint8List? imageData,
    String? imagePath,
    int? quantity,
    bool? isFromPreset,
    int? categoryId,
  }) {
    return GiveAwayItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      isFromPreset: isFromPreset ?? this.isFromPreset,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
