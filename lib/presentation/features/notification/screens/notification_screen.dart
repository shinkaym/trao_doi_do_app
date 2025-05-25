import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/notification/widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Thông báo', style: theme.textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).textTheme.titleLarge?.color,
            indicatorColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Đã Xem'),
              Tab(text: 'Chưa xem'),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Đánh dấu tất cả đã đọc
              },
              child: const Text('Đọc tất cả'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(),
                _buildNotificationList(),
                _buildNotificationList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView(
      children: const [
        NotificationTile(
          icon: Icons.check,
          title: 'Yêu cầu đã được chấp nhận',
          subtitle: 'Yêu cầu nhận lại ví tiền của bạn đã được chấp nhận',
          time: '5 phút trước',
        ),
        NotificationTile(
          icon: Icons.schedule,
          title: 'Yêu cầu đang xử lý',
          subtitle: 'Yêu cầu nhận lại chia khóa đang được xem xét',
          time: '30 phút trước',
        ),
        NotificationTile(
          icon: Icons.close,
          title: 'Yêu cầu đã bị từ chối',
          subtitle: 'Yêu cầu nhận lại điện thoại không được chấp nhận',
          time: '1 giờ trước',
        ),
      ],
    );
  }
}
