import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_websocket_provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ChatWebSocketState webSocketState;
  final bool isTablet;

  const ConnectionStatusWidget({
    super.key,
    required this.webSocketState,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (webSocketState.isConnecting) {
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
              'Đang kết nối...',
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
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
