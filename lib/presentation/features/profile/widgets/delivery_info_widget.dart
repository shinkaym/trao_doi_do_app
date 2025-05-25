import 'package:flutter/material.dart';

class DeliveryInfoWidget extends StatelessWidget {
  const DeliveryInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin gửi đồ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Vui lòng mang theo CMND/CCCD khi đến gửi đồ'),
          Text('• Đóng gói món đồ cẩn thận và sạch sẽ (nếu có thể)'),
          Text('• Kiểm tra kỹ món đồ kỹ lưỡng trước khi gửi'),
        ],
      ),
    );
  }
}
