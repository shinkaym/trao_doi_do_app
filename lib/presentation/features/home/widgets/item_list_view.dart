import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_tile.dart';

class ItemListView extends StatelessWidget {
  final List<ItemTile> items = const [
    ItemTile(
      time: '5 giờ trước',
      quantity: '1',
      name: 'Máy tính xách tay',
      imageUrl: 'https://picsum.photos/250?image=9',
      address: 'Tòa F, Lầu 5, Phòng F512',
    ),
    ItemTile(
      time: '3 giờ trước',
      quantity: '2',
      name: 'Ô dù',
      imageUrl: 'https://picsum.photos/250?image=10',
      address: 'Tòa A, Lầu 3, Phòng A301',
    ),
    ItemTile(
      time: '1 giờ trước',
      quantity: '1',
      name: 'Sách lập trình',
      imageUrl: 'https://picsum.photos/250?image=11',
      address: 'Thư viện trường, tầng 2',
    ),
  ];

  const ItemListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12), // Khoảng cách giữa các ListTile
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}