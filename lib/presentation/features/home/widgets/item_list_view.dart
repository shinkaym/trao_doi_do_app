import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_tile.dart';

class ItemListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemTile(
          name: item['name'] ?? '',
          time: item['time'] ?? '',
          quantity: item['quantity'] ?? '',
          imageUrl: item['imageUrl'] ?? '',
          address: item['address'] ?? '',
          onTap: () {
            context.pushNamed(
              'item_detail',
              pathParameters: {'id': item['id'] ?? ''},
              extra: item,
            );
          },
        );
      },
    );
  }
}