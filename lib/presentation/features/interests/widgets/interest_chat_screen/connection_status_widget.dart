import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_websocket_provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ChatWebSocketState webSocketState;
  final bool isTablet;
  final VoidCallback? onReconnect;
  final bool isReconnecting;

  const ConnectionStatusWidget({
    super.key,
    required this.webSocketState,
    required this.isTablet,
    this.onReconnect,
    this.isReconnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (webSocketState.isConnecting || isReconnecting) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.orange.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isReconnecting ? 'Đang kết nối lại...' : 'Đang kết nối...',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      );
    } else if (!webSocketState.isConnected) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Text(
              'Mất kết nối',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            if (onReconnect != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onReconnect,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
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

    return const SizedBox.shrink();
  }
}
