import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String status;

  const StatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    String header;
    String desc;

    switch (status) {
      case 'Đã duyệt':
        icon = const Icon(Icons.check_circle, color: Colors.green, size: 36);
        header = 'Đã duyệt';
        desc =
            'Yêu cầu của bạn đã được chấp nhận. Vui lòng đến địa điểm và thời gian đã hẹn.';
        break;
      case 'Từ chối':
        icon = const Icon(Icons.cancel, color: Colors.red, size: 36);
        header = 'Từ chối';
        desc =
            'Yêu cầu của bạn đã bị từ chối. Vui lòng kiểm tra lại thông tin hoặc liên hệ để biết thêm chi tiết.';
        break;
      default:
        icon = const Icon(Icons.access_time, color: Colors.orange, size: 36);
        header = 'Đang xử lý';
        desc =
            'Yêu cầu của bạn đang được xem xét. Chúng tôi sẽ thông báo khi có kết quả.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(desc),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
