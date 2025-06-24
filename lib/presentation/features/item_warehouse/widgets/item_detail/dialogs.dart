import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

Future<bool> showRegisterDialog(
  BuildContext context,
  Map<String, dynamic> item,
) async {
  final result = await context.showAppDialog<bool>(
    child: AlertDialog(
      title: const Text('Xác nhận đăng ký'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn có chắc chắn muốn đăng ký nhận món đồ này?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lưu ý quan trọng:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...item['rules']
                    .map<Widget>(
                      (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                            Expanded(
                              child: Text(
                                rule,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSuccessDialog(BuildContext context) {
  context.showSuccessDialog(
    title: 'Đăng ký thành công!',
    message:
        'Chúng tôi đã ghi nhận đăng ký của bạn. Người tặng sẽ liên hệ với bạn sớm nhất.',
    buttonText: 'Đồng ý',
  );
}
