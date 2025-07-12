import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/notifiers/notification_websocket_notifier.dart';

class NotificationConnectionStatusWidget extends StatelessWidget {
  final NotificationWebSocketState webSocketState;
  final bool isTablet;
  final VoidCallback? onReconnect;
  final bool isReconnecting;

  const NotificationConnectionStatusWidget({
    super.key,
    required this.webSocketState,
    required this.isTablet,
    this.onReconnect,
    this.isReconnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (webSocketState.isConnecting || isReconnecting) {
      return _buildConnectionStatus(
        color: Colors.orange,
        icon: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
        message:
            isReconnecting
                ? 'Đang kết nối lại...'
                : 'Đang kết nối thông báo...',
      );
    } else if (!webSocketState.isConnected) {
      return _buildConnectionStatus(
        color: Colors.red,
        icon: Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
        message: 'Mất kết nối thông báo',
        showReconnect: onReconnect != null,
        onReconnect: onReconnect,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildConnectionStatus({
    required Color color,
    required Widget icon,
    required String message,
    bool showReconnect = false,
    VoidCallback? onReconnect,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: color.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(message, style: TextStyle(color: color, fontSize: 12)),
          if (showReconnect && onReconnect != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onReconnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Kết nối lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
