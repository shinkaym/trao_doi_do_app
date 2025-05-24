import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/item.dart';

class ItemSlider extends StatelessWidget {
  // Danh sách các mục Item
  final List<Item> items = const [
    Item(
      message: 'Vì đâu mà mưa, bên trong có gì để tôi tìm mà trong mưa tôi tìm...',
      sender: 'Mike',
      time: '5 giờ trước',
      badge: 'SL1',
    ),
    Item(
      message: 'Hôm nay trời đẹp, tôi muốn đi dạo nhưng lại không có ai đi cùng...',
      sender: 'Anna',
      time: '3 giờ trước',
      badge: 'SL2',
    ),
    Item(
      message: 'Có ai biết quán cà phê nào yên tĩnh để học bài không?',
      sender: 'John',
      time: '1 giờ trước',
      badge: 'SL3',
    ),
  ];

  @override
  const ItemSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200, // Chiều cao của slide
        autoPlay: true, // Tự động chạy
        autoPlayInterval: const Duration(seconds: 3), // Thời gian mỗi slide
        enlargeCenterPage: true, // Phóng to slide ở giữa
        viewportFraction: 0.9, // Tỷ lệ hiển thị của mỗi slide
      ),
      items: items.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: item,
            );
          },
        );
      }).toList(),
    );
  }
}