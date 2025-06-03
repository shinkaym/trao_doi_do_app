import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

// Model cho notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'system', 'item', 'post', 'trade', 'message'
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? targetId; // ID của item/post/trade để navigate
  final String? deepLink; // Deep link nội bộ app
  final String? webUrl; // URL website để mở bằng URL launcher
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.targetId,
    this.deepLink,
    this.webUrl,
    this.metadata,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'unread', 'read'
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      // Giả lập data thông báo
      await Future.delayed(const Duration(seconds: 1));

      _notifications = [
        NotificationModel(
          id: '1',
          title: 'Có người quan tâm đến món đồ của bạn',
          message: 'Nguyễn Văn B đã thích chiếc áo khoác bạn đăng bán',
          type: 'item',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          imageUrl: 'https://dummyimage.com/60x60/000/fff',
          targetId: 'item_123',
          deepLink: '/item-detail/item_123',
        ),
        NotificationModel(
          id: '2',
          title: 'Tin nhắn mới',
          message: 'Bạn có tin nhắn mới từ Trần Thị C về việc trao đổi',
          type: 'message',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
          targetId: 'chat_456',
          deepLink: '/chat/chat_456',
        ),
        NotificationModel(
          id: '3',
          title: 'Giao dịch thành công',
          message: 'Bạn đã hoàn thành giao dịch trao đổi với Lê Văn D',
          type: 'trade',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
          targetId: 'trade_789',
          deepLink: '/trade-detail/trade_789',
        ),
        NotificationModel(
          id: '4',
          title: 'Bài đăng mới phù hợp',
          message: 'Có bài đăng mới về "iPhone 13" phù hợp với nhu cầu của bạn',
          type: 'post',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          imageUrl: 'https://dummyimage.com/60x60/000/fff',
          targetId: 'post_101',
          deepLink: '/post-detail/post_101',
        ),
        NotificationModel(
          id: '5',
          title: 'Cập nhật ứng dụng v2.1.0',
          message:
              'Ứng dụng đã được cập nhật với nhiều tính năng mới và cải thiện hiệu suất',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          webUrl: 'https://flutter.dev', // URL sẽ được mở bằng URL launcher
        ),
        NotificationModel(
          id: '6',
          title: 'Hướng dẫn sử dụng tính năng mới',
          message: 'Tìm hiểu cách sử dụng tính năng trao đổi thông minh mới',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: false,
          webUrl: 'https://flutter.dev',
        ),
      ];

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('Lỗi khi tải thông báo: $e');
      }
    }
  }

  List<NotificationModel> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      default:
        return _notifications;
    }
  }

  List<NotificationModel> _getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            createdAt: notification.createdAt,
            isRead: true,
            imageUrl: notification.imageUrl,
            targetId: notification.targetId,
            deepLink: notification.deepLink,
            webUrl: notification.webUrl,
            metadata: notification.metadata,
          );
        }
      });

      // Gửi API để đánh dấu đã đọc
      // await NotificationService.markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications =
          _notifications
              .map(
                (n) => NotificationModel(
                  id: n.id,
                  title: n.title,
                  message: n.message,
                  type: n.type,
                  createdAt: n.createdAt,
                  isRead: true,
                  imageUrl: n.imageUrl,
                  targetId: n.targetId,
                  deepLink: n.deepLink,
                  webUrl: n.webUrl,
                  metadata: n.metadata,
                ),
              )
              .toList();
    });

    context.showSuccessSnackBar('Đã đánh dấu tất cả thông báo là đã đọc');
  }

  // Thêm hàm để launch URL
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Mở trong browser mặc định
        );
      } else {
        if (mounted) {
          context.showErrorSnackBar('Không thể mở liên kết: $url');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Lỗi khi mở liên kết: $e');
      }
    }
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Đánh dấu đã đọc
    await _markAsRead(notification);

    // Điều hướng dựa trên loại thông báo
    if (notification.webUrl != null && notification.webUrl!.isNotEmpty) {
      // Mở URL bằng URL launcher
      await _launchUrl(notification.webUrl!);
    } else if (notification.deepLink != null &&
        notification.deepLink!.isNotEmpty) {
      context.push(notification.deepLink!);
    } else {
      // Fallback navigation dựa trên type
      switch (notification.type) {
        case 'item':
          if (notification.targetId != null) {
            context.pushNamed(
              'item-detail',
              pathParameters: {'id': notification.targetId!},
            );
          }
          break;
        case 'post':
          if (notification.targetId != null) {
            context.pushNamed(
              'post-detail',
              pathParameters: {'id': notification.targetId!},
            );
          }
          break;
        case 'trade':
          if (notification.targetId != null) {
            context.pushNamed(
              'trade-detail',
              pathParameters: {'id': notification.targetId!},
            );
          }
          break;
        case 'message':
          if (notification.targetId != null) {
            context.pushNamed(
              'chat',
              pathParameters: {'id': notification.targetId!},
            );
          }
          break;
        case 'system':
          // Nếu không có webUrl, hiển thị dialog
          _showSystemNotificationDialog(notification);
          break;
      }
    }
  }

  void _showSystemNotificationDialog(NotificationModel notification) {
    context.showInfoDialog(
      title: notification.title,
      content: notification.message,
      buttonText: 'Đóng',
      icon: Icons.info_outline,
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'item':
        return Icons.shopping_bag_outlined;
      case 'post':
        return Icons.article_outlined;
      case 'trade':
        return Icons.swap_horiz;
      case 'message':
        return Icons.message_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    final theme = context.theme;
    switch (type) {
      case 'item':
        return Colors.blue;
      case 'post':
        return Colors.green;
      case 'trade':
        return Colors.orange;
      case 'message':
        return theme.colorScheme.primary;
      case 'system':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: CustomAppBar(
        title: 'Thông báo',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        showNotificationButton: false,
        additionalActions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.mark_email_read_outlined, size: 18),
              label: const Text(
                'Đọc tất cả',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              indicatorColor: theme.colorScheme.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tất cả'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Giao dịch'),
                const Tab(text: 'Tin nhắn'),
                const Tab(text: 'Hệ thống'),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tất cả thông báo
                        _buildNotificationList(_filteredNotifications),
                        // Giao dịch
                        _buildNotificationList(
                          _getNotificationsByType('trade') +
                              _getNotificationsByType('item'),
                        ),
                        // Tin nhắn
                        _buildNotificationList(
                          _getNotificationsByType('message'),
                        ),
                        // Hệ thống
                        _buildNotificationList(
                          _getNotificationsByType('system'),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    final isTablet = context.isTablet;

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        itemCount: notifications.length,
        separatorBuilder:
            (context, index) => SizedBox(height: isTablet ? 12 : 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isTablet = context.isTablet;
    final theme = context.theme;

    return Card(
      elevation: notification.isRead ? 1 : 3,
      color:
          notification.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.primary.withOpacity(0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            notification.isRead
                ? BorderSide.none
                : BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon hoặc Avatar
              Container(
                width: isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child:
                    notification.imageUrl != null &&
                            notification.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            notification.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  _getNotificationIcon(notification.type),
                                  color: _getNotificationColor(
                                    notification.type,
                                  ),
                                  size: isTablet ? 26 : 22,
                                ),
                          ),
                        )
                        : Icon(
                          _getNotificationIcon(notification.type),
                          color: _getNotificationColor(notification.type),
                          size: isTablet ? 26 : 22,
                        ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                              color:
                                  notification.isRead
                                      ? theme.textTheme.bodyLarge?.color
                                      : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      _getTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: theme.hintColor.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.hintColor.withOpacity(0.5),
                size: isTablet ? 24 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
