import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/providers/chat_notification_websocket_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/unread_count_provider.dart';

class CustomBottomNavigation extends HookConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng useAnimationController thay cho AnimationController
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    // Sử dụng useMemoized để tạo animation
    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    // Watch auth state và providers
    final authState = ref.watch(authProvider);
    final chatNotificationState = ref.watch(chatNotificationWebSocketProvider);
    final unreadCountState = ref.watch(unreadCountProvider);

    // Notifiers
    final chatNotificationNotifier = ref.read(
      chatNotificationWebSocketProvider.notifier,
    );
    final unreadCountNotifier = ref.read(unreadCountProvider.notifier);
    final getAccessTokenUseCase = ref.read(getAccessTokenUseCaseProvider);

    // Load unread count khi widget được build lần đầu
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(unreadCountProvider.notifier).loadUnreadCount();
      });
      return null;
    }, []);

    // Lắng nghe WebSocket messages để tự động tăng unread count
    ref.listen<ChatNotificationWebSocketState>(
      chatNotificationWebSocketProvider,
      (previous, next) {
        // Kiểm tra nếu có tin nhắn mới từ WebSocket
        if (previous?.lastResponse != next.lastResponse &&
            next.lastResponse?.event == 'send_message_response' &&
            next.lastResponse?.isSuccess == true &&
            next.lastResponse?.data != null) {
          print('📨 New message received, increasing unread count');

          // Tăng unread count thêm 1
          unreadCountNotifier.updateCount(unreadCountState.count + 1);

          // Có thể thêm haptic feedback để thông báo cho user
          HapticFeedback.lightImpact();
        }

        // Xử lý các event khác nếu cần
        if (previous?.lastResponse != next.lastResponse &&
            next.lastResponse != null) {
          switch (next.lastResponse!.event) {
            case 'new_chat_notification':
              // Xử lý notification chat khác
              print('📢 New chat notification received');
              unreadCountNotifier.updateCount(unreadCountState.count + 1);
              break;

            case 'mark_as_read_response':
              // Có thể reset unread count nếu server báo đã đọc
              if (next.lastResponse!.isSuccess) {
                print('✅ Messages marked as read');
                // Không cần làm gì vì user sẽ tự decrease count khi vào chat
              }
              break;

            default:
              // Xử lý các event khác
              break;
          }
        }
      },
    );

    // Kết nối tới chat notification WebSocket khi đã đăng nhập
    useEffect(() {
      Future.microtask(() async {
        if (authState.isLoggedIn &&
            authState.user != null &&
            !chatNotificationState.isConnected &&
            !chatNotificationState.isConnecting) {
          print('🔌 Connecting to chat notification WebSocket...');

          final result = await getAccessTokenUseCase.execute();
          result.fold(
            (failure) => {
              print(
                '❌ Failed to get access token for chat notification: ${failure.message}',
              ),
            },
            (token) =>
                chatNotificationNotifier.connectToChatNotification(token),
          );
        }

        // Ngắt kết nối khi đăng xuất
        if (!authState.isLoggedIn && chatNotificationState.isConnected) {
          print('🔌 Disconnecting from chat notification WebSocket...');
          chatNotificationNotifier.disconnect();
        }
      });
      return null;
    }, [authState.isLoggedIn, authState.user]);

    // Xử lý WebSocket connection state changes
    useEffect(() {
      if (chatNotificationState.isConnected) {
        print('✅ Chat notification WebSocket connected');
      } else if (chatNotificationState.hasError) {
        print(
          '❌ Chat notification WebSocket error: ${chatNotificationState.error}',
        );
      }
      return null;
    }, [chatNotificationState.connectionState]);

    // Xử lý lỗi WebSocket
    useEffect(() {
      if (chatNotificationState.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('❌ Chat notification error: ${chatNotificationState.error}');
        });
      }
      return null;
    }, [chatNotificationState.error]);

    // Function để xử lý tap
    void onItemTapped(int index) {
      if (index != currentIndex) {
        HapticFeedback.lightImpact();
        animationController.forward().then((_) {
          animationController.reverse();
        });
        onTap(index);
      }
    }

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: isTablet ? 80 : 70,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 12 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                NavBarConstants.navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildNavItem(
                    context,
                    item,
                    index,
                    isTablet,
                    scaleAnimation,
                    onItemTapped,
                    unreadCountState,
                    chatNotificationState,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationItemConfig item,
    int index,
    bool isTablet,
    Animation<double> scaleAnimation,
    Function(int) onItemTapped,
    UnreadCountState unreadCountState,
    ChatNotificationWebSocketState chatNotificationState,
  ) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isSelected = currentIndex == index;

    final isInterestsTab = index == 3;

    // Tổng unread count từ unread count provider và chat notification counts
    final totalUnreadCount = unreadCountState.count;

    final hasUnreadMessages = isInterestsTab && totalUnreadCount > 0;

    if (item.isSpecial) {
      return _buildSpecialButton(
        context,
        item,
        index,
        isTablet,
        onItemTapped,
        hasUnreadMessages,
        totalUnreadCount,
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? scaleAnimation.value : 1.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 8 : 6,
                  horizontal: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isTablet ? 4 : 2),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            size: isTablet ? 26 : 22,
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : theme.hintColor.withOpacity(0.7),
                          ),
                        ),
                        // Badge cho tin nhắn chưa đọc
                        if (hasUnreadMessages)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: _buildUnreadBadge(
                              context,
                              totalUnreadCount,
                              isTablet,
                            ),
                          ),
                      ],
                    ),
                    if (showLabels) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : theme.hintColor.withOpacity(0.8),
                        ),
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialButton(
    BuildContext context,
    NavigationItemConfig item,
    int index,
    bool isTablet,
    Function(int) onItemTapped,
    bool hasUnreadMessages,
    int unreadCount,
  ) {
    final colorScheme = context.colorScheme;
    final isSelected = currentIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isTablet ? 60 : 50,
          height: isTablet ? 60 : 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isSelected
                      ? [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ]
                      : [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.8),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isSelected
                        ? colorScheme.primary
                        : colorScheme.primaryContainer)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.inactiveIcon,
                    size: isTablet ? 28 : 24,
                    color:
                        isSelected
                            ? Colors.white
                            : colorScheme.onPrimaryContainer,
                  ),
                  if (showLabels) ...[
                    SizedBox(height: isTablet ? 2 : 1),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: isTablet ? 10 : 8,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? Colors.white
                                : colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              // Badge cho special button
              if (hasUnreadMessages)
                Positioned(
                  right: -4,
                  top: -4,
                  child: _buildUnreadBadge(context, unreadCount, isTablet),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(BuildContext context, int count, bool isTablet) {
    final badgeText = count > 99 ? '99+' : count.toString();
    final fontSize = isTablet ? 10.0 : 8.0;
    final badgeSize = isTablet ? 20.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(minWidth: badgeSize, minHeight: badgeSize),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 6 : 4,
        vertical: isTablet ? 2 : 1,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          badgeText,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
