import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_single.dart';

class ItemPageView extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemPageView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: ItemSingle(
              description: item['description'] ?? '',
              sender: item['sender'] ?? '',
              time: item['time'] ?? '',
              quantity: item['quantity'] ?? '',
              name: item['name'] ?? '',
              imageUrl: item['imageUrl'] ?? '',
              address: item['address'] ?? '',
            ),
          );
        },
      ),
    );
  }
}