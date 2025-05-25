import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_single.dart';

class ItemPageView extends StatelessWidget {
  final List<ItemSingle> items = const [
    ItemSingle(
      description:
          'Vì đâu mà mưa, bên trong có gì để tôi tìm mà trong mưa tôi tìm mà trong mưa tôi tìm mà trong mưa tôi tìm...',
      sender: 'Mike',
      time: '5 giờ trước',
      quantity: '1',
      name: 'Máy tính xách tay',
      imageUrl: 'https://picsum.photos/250?image=9',
      address: 'Tòa F, Lầu 5, Phòng F512',
    ),
    ItemSingle(
      description:
          'Hôm nay trời đẹp, tôi muốn đi dạo nhưng lại không có ai đi cùng nên tôi quyết định tìm một chiếc ô để che nắng...',
      sender: 'Anna',
      time: '3 giờ trước',
      quantity: '2',
      name: 'Ô dù',
      imageUrl: 'https://picsum.photos/250?image=10',
      address: 'Tòa A, Lầu 3, Phòng A301',
    ),
    ItemSingle(
      description:
          'Có ai biết quán cà phê nào yên tĩnh để học bài không? Tôi tìm mãi mà không thấy...',
      sender: 'John',
      time: '1 giờ trước',
      quantity: '1',
      name: 'Sách lập trình',
      imageUrl: 'https://picsum.photos/250?image=11',
      address: 'Thư viện trường, tầng 2',
    ),
  ];

  const ItemPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Chiều cao của PageView (tùy chỉnh theo nội dung)
      child: PageView.builder(
        controller: PageController(
          viewportFraction: 0.9, // Tỷ lệ hiển thị của mỗi trang
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: items[index],
          );
        },
      ),
    );
  }
}