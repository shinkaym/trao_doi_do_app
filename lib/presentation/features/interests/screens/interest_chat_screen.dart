import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/chat_app_bar.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/post_info_header.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/connection_status_widget.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/message_input_widget.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/messages_list_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';

class InterestChatScreen extends HookConsumerWidget {
  final String interestId;

  const InterestChatScreen({super.key, required this.interestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interestDetailState = ref.watch(
      interestDetailProvider(int.parse(interestId)),
    );
    final interestDetail = interestDetailState.interestDetail;

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messageFocusNode = useFocusNode();

    final isLoading = useState(true);
    final isSending = useState(false);
    final hasMarkedAsRead = useState(
      false,
    ); // Thêm flag để tránh đánh dấu đã đọc nhiều lần

    final isPostOwner = useState<bool>(false);
    final displayName = useState<String>('');
    final displayAvatar = useState<String>('');
    final displayUserId = useState<int?>(null);

    // Watch providers
    final authState = ref.watch(authProvider);
    final messagesState = ref.watch(
      messagesListProvider(int.parse(interestId)),
    );
    final messagesNotifier = ref.read(
      messagesListProvider(int.parse(interestId)).notifier,
    );
    final transactionsState = ref.watch(transactionsListProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);

    // WebSocket providers
    final webSocketState = ref.watch(chatWebSocketProvider);
    final webSocketNotifier = ref.read(chatWebSocketProvider.notifier);

    final getAccessTokenUseCase = ref.read(getAccessTokenUseCaseProvider);

    useEffect(() {
      Future.microtask(() async {
        if (interestDetailState.interestDetail == null &&
            !interestDetailState.isLoading) {
          await ref
              .read(interestDetailProvider(int.parse(interestId)).notifier)
              .loadInterestDetail(int.parse(interestId));
        }
      });
      return null;
    }, []);

    // Initialize chat data and load messages/transactions
    useEffect(() {
      Future.microtask(() async {
        if (interestDetail != null && authState.user != null) {
          try {
            // Set post data from route params
            isPostOwner.value = interestDetail.authorID == authState.user!.id;

            // Set display information based on user role
            if (isPostOwner.value) {
              // Post owner sees the interested user's info
              final interestedUser = interestDetail.interests.firstWhere(
                (i) => i.id.toString() == interestId,
                orElse: () => throw Exception('Interested user not found'),
              );
              displayName.value = interestedUser.userName;
              displayAvatar.value = interestedUser.userAvatar;
              displayUserId.value = interestedUser.userID;
            } else {
              // Interested user sees the post author's info
              displayName.value = interestDetail.authorName;
              displayAvatar.value = interestDetail.authorAvatar;
              displayUserId.value = interestDetail.authorID;
            }

            // Connect to WebSocket if not already connected
            if (!webSocketState.isConnected && !webSocketState.isConnecting) {
              final result = await getAccessTokenUseCase.execute();
              result.fold(
                (failure) => {},
                (token) => webSocketNotifier.connectToChat(token),
              );
            }

            // Join the chat room
            if (webSocketState.isConnected) {
              webSocketNotifier.joinRoom(int.parse(interestId));
            }

            // Load messages
            await messagesNotifier.loadMessages(refresh: true);

            // Load transactions with default query
            final query = TransactionsQuery(
              sort: 'createdAt',
              order: 'DESC',
              postID: interestDetail.id,
              searchBy: 'interestID',
              searchValue: interestId,
            );

            await transactionsNotifier.loadTransactions(
              newQuery: query,
              refresh: true,
            );

            isLoading.value = false;

            // Scroll to bottom after loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom(scrollController);
            });
          } catch (e) {
            isLoading.value = false;
          }
        }
      });
      return null;
    }, [interestDetail, authState.user]);

    // Tự động đánh dấu đã đọc tin nhắn khi load xong messages
    useEffect(() {
      if (!messagesState.isLoading &&
          messagesState.messages.isNotEmpty &&
          !hasMarkedAsRead.value &&
          messagesNotifier.unreadCount > 0) {
        Future.microtask(() async {
          try {
            await messagesNotifier.markAllAsRead();
            hasMarkedAsRead.value = true;
          } catch (e) {}
        });
      }
      return null;
    }, [messagesState.isLoading, messagesState.messages]);

    // Đánh dấu đã đọc khi có tin nhắn mới từ WebSocket
    useEffect(() {
      if (messagesState.messages.isNotEmpty &&
          messagesNotifier.unreadCount > 0) {
        // Delay một chút để đảm bảo user nhìn thấy tin nhắn
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (messagesNotifier.unreadCount > 0) {
            messagesNotifier.markAllAsRead();
          }
        });
      }
      return null;
    }, [messagesState.messages.length]);

    // Handle WebSocket connection state changes
    useEffect(() {
      if (webSocketState.isConnected && authState.user != null) {
        // Join room when connected
        webSocketNotifier.joinRoom(int.parse(interestId));
      }
      return null;
    }, [webSocketState.isConnected]);

    // Handle WebSocket connection when auth state changes
    useEffect(() {
      () async {
        if (authState.user != null &&
            !webSocketState.isConnected &&
            !webSocketState.isConnecting) {
          final result = await getAccessTokenUseCase.execute();
          result.fold(
            (failure) => {},
            (token) => webSocketNotifier.connectToChat(token),
          );
        }
      }();
      return null;
    }, [authState.user]);

    // Handle new WebSocket messages
    void _handleNewWebSocketMessage() {
      final response = webSocketState.lastResponse;
      if (response == null) return;

      if (response.event == 'send_message_response' &&
          response.isSuccess &&
          response.data != null) {
        final messageData = response.data!;
        final interestID = messageData['interestID'] as int?;

        if (interestID == int.parse(interestId)) {
          try {
            // Validate required fields
            if (messageData['senderID'] == null || authState.user?.id == null) {
              return;
            }

            // Use the factory constructor
            final message = Message.fromWebSocket(
              messageData,
              interestID: int.parse(interestId),
              currentUserId: authState.user!.id,
              otherUserId: displayUserId.value,
            );

            // Check if message already exists
            final existingMessage =
                messagesState.messages.where((m) {
                  if (messageData['id'] != null && m.id == messageData['id']) {
                    return true;
                  }
                  return m.message == message.message &&
                      m.senderID == message.senderID &&
                      m.createdAt != null &&
                      message.createdAt != null &&
                      m.createdAt!
                              .difference(message.createdAt!)
                              .abs()
                              .inSeconds <
                          3;
                }).firstOrNull;

            if (existingMessage == null) {
              messagesNotifier.addNewMessage(message);

              // Scroll to bottom after adding message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  _scrollToBottom(scrollController);
                }
              });
            }
          } catch (e) {}
        }
      }
    }

    useEffect(() {
      if (webSocketState.lastResponse != null) {
        Future.microtask(_handleNewWebSocketMessage);
      }
      return null;
    }, [webSocketState.lastResponse]);

    // Handle WebSocket errors
    useEffect(() {
      if (webSocketState.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showErrorSnackBar('WebSocket Error: ${webSocketState.error}');
          webSocketNotifier.clearError();
        });
      }
      return null;
    }, [webSocketState.error]);

    // Handle scroll for loading more messages
    useEffect(() {
      final debouncer = Debouncer();

      void handleScroll() {
        if (scrollController.position.pixels <= 50 &&
            !messagesState.isLoadingMore &&
            messagesState.hasMoreData &&
            scrollController.hasClients) {
          debouncer.debounce(
            duration: const Duration(milliseconds: 500),
            onDebounce: () async {
              final currentScrollPosition = scrollController.position.pixels;
              final currentExtent = scrollController.position.maxScrollExtent;

              await messagesNotifier.loadMore();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  final newExtent = scrollController.position.maxScrollExtent;
                  final extentDelta = newExtent - currentExtent;

                  scrollController.animateTo(
                    currentScrollPosition + extentDelta,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          );
        }
      }

      scrollController.addListener(handleScroll);
      return () => scrollController.removeListener(handleScroll);
    }, [messagesState.isLoadingMore, messagesState.hasMoreData]);

    // Handle transaction state changes
    useEffect(() {
      if (transactionsState.failure != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showErrorSnackBar(
            'Lỗi tải giao dịch: ${transactionsState.failure!.message}',
          );
        });
      }
      return null;
    }, [transactionsState.failure]);

    // Handle messages state changes
    useEffect(() {
      if (messagesState.failure != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showErrorSnackBar(
            'Lỗi tải tin nhắn: ${messagesState.failure!.message}',
          );
        });
      }
      return null;
    }, [messagesState.failure]);

    // Cleanup when leaving the screen
    useEffect(() {
      return () {
        if (webSocketState.isConnected) {
          webSocketNotifier.leftRoom(int.parse(interestId));
        }
      };
    }, []);

    // Event handlers
    void sendMessage() async {
      final messageText = messageController.text.trim();
      if (messageText.isEmpty || isSending.value || authState.user == null)
        return;

      if (!webSocketState.isConnected) {
        context.showWarningSnackBar(
          'Không thể gửi tin nhắn. Đang kết nối lại...',
        );
        return;
      }

      isSending.value = true;
      messageController.clear();

      try {
        webSocketNotifier.sendMessage(
          interestID: int.parse(interestId),
          isOwner: isPostOwner.value,
          userID: displayUserId.value!,
          message: messageText,
        );
      } catch (e) {
        context.showErrorSnackBar('Lỗi gửi tin nhắn: $e');
      } finally {
        isSending.value = false;
      }
    }

    void handlePostTap() {
      if (interestDetail != null) {
        context.pushNamed(
          'post-detail',
          pathParameters: {'slug': interestDetail.slug},
        );
      }
    }

    void handleTransactionTap() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => TransactionListBottomSheet(
              transactions: transactionsState.transactions,
              postType: interestDetail?.type,
              isPostOwner: isPostOwner.value,
              items: interestDetail?.items ?? [],
              onTransactionUpdated: (updatedTransaction) {
                webSocketNotifier.sendTransaction(
                  interestID: int.parse(interestId),
                  receiverID: displayUserId.value!,
                );
              },
            ),
      );
    }

    void handleItemTransactionTap() {
      if (isPostOwner.value) return;

      final latestTransaction =
          transactionsState.transactions.isNotEmpty
              ? transactionsState.transactions.first
              : null;

      final canCreateTransaction =
          latestTransaction == null || latestTransaction.status != 1;

      if (!canCreateTransaction) {
        // Thay đổi message dựa trên post type
        final waitMessage =
            interestDetail?.type == PostType.findLost.value
                ? 'Đợi phản hồi từ chủ bài viết'
                : 'Đợi yêu cầu mới nhất được phản hồi';
        context.showInfoSnackBar(waitMessage);
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => TransactionItemSelectionBottomSheet(
              postItems: interestDetail?.items ?? [],
              interestId: int.parse(interestId),
              postType: interestDetail?.type,
              onTransactionSent: () {
                transactionsNotifier.refresh();
                webSocketNotifier.sendTransaction(
                  interestID: int.parse(interestId),
                  receiverID: displayUserId.value!,
                );
              },
            ),
      );
    }

    void handleRefreshTransactions() {
      transactionsNotifier.refresh();
    }

    useEffect(() {
      final response = webSocketState.lastResponse;
      if (response?.event == 'send_transaction_response') {
        if (response!.isSuccess) {
          // Use Future.microtask to avoid state modification during build
          Future.microtask(() {
            handleRefreshTransactions();
          });
        }
      }
      return null;
    }, [webSocketState.lastResponse]);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    if (isLoading.value || !authState.isInitialized) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: 'Trò chuyện',
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: CustomAppBar(
          title: 'Trò chuyện',
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
        body: const Center(
          child: Text('Bạn cần đăng nhập để sử dụng chức năng này'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: ChatAppBar(
        displayName: displayName.value,
        displayAvatar: displayAvatar.value,
        isPostOwner: isPostOwner.value,
        isTablet: isTablet,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // WebSocket connection status indicator
            ConnectionStatusWidget(
              webSocketState: webSocketState,
              isTablet: isTablet,
            ),

            // Post info header
            if (interestDetail != null)
              PostInfoHeader(
                transactions: transactionsState.transactions,
                post: interestDetail,
                isPostOwner: isPostOwner.value,
                isLoadingTransactions: transactionsState.isLoading,
                isTablet: isTablet,
                onPostTap: handlePostTap,
                onTransactionTap: handleTransactionTap,
                onRefreshTransactions: handleRefreshTransactions,
              ),

            // Messages list
            Expanded(
              child: MessagesListWidget(
                messagesState: messagesState,
                messagesNotifier: messagesNotifier,
                scrollController: scrollController,
                authState: authState,
                displayName: displayName.value,
                displayAvatar: displayAvatar.value,
                isTablet: isTablet,
                onPostTap: handlePostTap,
              ),
            ),

            // Message input
            MessageInputWidget(
              messageController: messageController,
              messageFocusNode: messageFocusNode,
              isSending: isSending.value,
              isPostOwner: isPostOwner.value,
              isWebSocketConnected: webSocketState.isConnected,
              isTablet: isTablet,
              onSend: sendMessage,
              onItemTransaction: handleItemTransactionTap,
              postType: interestDetail?.type,
            ),
          ],
        ),
      ),
    );
  }
}

void _scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
