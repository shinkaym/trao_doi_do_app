class ItemModel {
  final String id;
  final String description;
  final String sender;
  final String time;
  final String quantity;
  final String name;
  final String imageUrl;
  final String address;

  ItemModel({
    required this.id,
    required this.description,
    required this.sender,
    required this.time,
    required this.quantity,
    required this.name,
    required this.imageUrl,
    required this.address,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      sender: json['sender'] ?? '',
      time: json['time'] ?? '',
      quantity: json['quantity'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
