import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/message_bubble.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/messages_provider.dart';

class MessagesListWidget extends StatelessWidget {
  final MessagesListState messagesState;
  final MessagesListNotifier messagesNotifier;
  final ScrollController scrollController;
  final AuthState authState;
  final String displayName;
  final String displayAvatar;
  final bool isTablet;
  final VoidCallback onPostTap;

  const MessagesListWidget({
    super.key,
    required this.messagesState,
    required this.messagesNotifier,
    required this.scrollController,
    required this.authState,
    required this.displayName,
    required this.displayAvatar,
    required this.isTablet,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    if (messagesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => messagesNotifier.refresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0 && messagesState.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final messageIndex =
                    messagesState.isLoadingMore ? index - 1 : index;
                final message = messagesState.messages[messageIndex];

                final isCurrentUser = message.senderID == authState.user!.id;
                final showAvatar =
                    messageIndex == messagesState.messages.length - 1 ||
                    messagesState.messages[messageIndex + 1].senderID !=
                        message.senderID;

                return MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  showAvatar: showAvatar,
                  isTablet: isTablet,
                  otherUserName: displayName,
                  otherUserAvatar: displayAvatar,
                  currentUserName: authState.user!.fullName,
                  currentUserAvatar: authState.user!.avatar,
                  onPostTap: onPostTap,
                  messages: messagesState.messages,
                  messageIndex: messageIndex,
                );
              },
              childCount:
                  messagesState.messages.length +
                  (messagesState.isLoadingMore ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }
}
