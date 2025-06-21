import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class MessageInputWidget extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final bool isSending;
  final bool isPostOwner;
  final bool isWebSocketConnected;
  final bool isTablet;
  final VoidCallback onSend;
  final VoidCallback onItemTransaction;

  const MessageInputWidget({
    super.key,
    required this.messageController,
    required this.messageFocusNode,
    required this.isSending,
    required this.isPostOwner,
    required this.isWebSocketConnected,
    required this.isTablet,
    required this.onSend,
    required this.onItemTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Transaction button (only for non-post-owner)
            if (!isPostOwner)
              IconButton(
                onPressed: onItemTransaction,
                icon: const Icon(Icons.shopping_cart),
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),

            SizedBox(width: isTablet ? 8 : 4),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: messageController,
                  focusNode: messageFocusNode,
                  decoration: InputDecoration(
                    hintText:
                        isWebSocketConnected
                            ? 'Nhập tin nhắn...'
                            : 'Đang kết nối...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                  style: TextStyle(fontSize: isTablet ? 15 : 14),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  enabled: !isSending && isWebSocketConnected,
                ),
              ),
            ),

            SizedBox(width: isTablet ? 8 : 4),

            // Send button
            Container(
              decoration: BoxDecoration(
                color:
                    isSending || !isWebSocketConnected
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isSending || !isWebSocketConnected ? null : onSend,
                icon:
                    isSending
                        ? SizedBox(
                          width: isTablet ? 20 : 16,
                          height: isTablet ? 20 : 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                        : const Icon(Icons.send),
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
