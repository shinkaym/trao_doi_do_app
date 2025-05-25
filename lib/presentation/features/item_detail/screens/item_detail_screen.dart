import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final String description;
  final String sender;
  final String time;
  final String quantity;
  final String name;
  final String imageUrl;
  final String address;

  const ItemDetailScreen({
    super.key,
    required this.description,
    required this.sender,
    required this.time,
    required this.quantity,
    required this.name,
    required this.imageUrl,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: const Center(child: Text('Hình ảnh không tải được')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tên: $name',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Số lượng: $quantity',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Tìm thấy tại: $address',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Mô tả: $description',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Người đăng: $sender',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Thời gian: $time',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}