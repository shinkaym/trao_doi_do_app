import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMoreData = true;

  late TabController _tabController;

  // Mock data
  List<Map<String, dynamic>> _requestsData = [];

  // Constants for request types and statuses
  static const Map<int, String> requestTypes = {
    0: 'Gửi đồ cũ',
    1: 'Nhận đồ cũ',
    2: 'Gửi đồ thất lạc',
    3: 'Nhận đồ thất lạc',
  };

  static const Map<int, String> requestStatuses = {
    0: 'Đang xử lý',
    1: 'Chờ phản hồi',
    2: 'Bị từ chối',
    3: 'Đã duyệt',
    4: 'Đã huỷ',
  };

  static const Map<int, Color> statusColors = {
    0: Colors.orange,
    1: Colors.blue,
    2: Colors.red,
    3: Colors.green,
    4: Colors.grey,
  };

  static const Map<int, IconData> typeIcons = {
    0: Icons.upload_outlined,
    1: Icons.download_outlined,
    2: Icons.help_outline,
    3: Icons.search_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Mock initial data
    _requestsData = _generateMockData(0, 10);
  }

  List<Map<String, dynamic>> _generateMockData(int startIndex, int count) {
    List<Map<String, dynamic>> data = [];
    final items = [
      {
        'name': 'Áo khoác jean',
        'description': 'Áo khoác jean màu xanh, size M, còn mới 90%',
      },
      {
        'name': 'Giày sneaker',
        'description': 'Giày thể thao màu trắng, size 42, ít sử dụng',
      },
      {'name': 'Túi xách', 'description': 'Túi xách da màu đen, còn đẹp'},
      {
        'name': 'Điện thoại',
        'description': 'iPhone 12, màu đen, thất lạc ở công viên',
      },
      {'name': 'Sách giáo khoa', 'description': 'Bộ sách toán lớp 12, còn mới'},
      {
        'name': 'Đồng hồ',
        'description': 'Đồng hồ thể thao màu đen, thất lạc ở trường',
      },
      {
        'name': 'Laptop',
        'description': 'Laptop Dell, màu bạc, cần tặng sinh viên',
      },
      {'name': 'Balo', 'description': 'Balo học sinh màu xanh, còn tốt'},
    ];

    final locations = [
      'Quận 1, TP.HCM',
      'Quận 3, TP.HCM',
      'Quận 7, TP.HCM',
      'Quận Thủ Đức, TP.HCM',
      'Quận Bình Thạnh, TP.HCM',
    ];

    for (int i = 0; i < count; i++) {
      final index = startIndex + i;
      final item = items[index % items.length];

      data.add({
        'id': index + 1,
        'requestType': index % 4,
        'status': index % 5,
        'itemName': item['name']!,
        'description': item['description']!,
        'appointmentTime': DateTime.now().add(Duration(days: index % 7 + 1)),
        'location': locations[index % locations.length],
        'createdAt': DateTime.now().subtract(Duration(days: index)),
      });
    }

    return data;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock loading more data
    List<Map<String, dynamic>> newData = _generateMockData(
      _requestsData.length,
      10,
    );

    if (_requestsData.length >= 50) {
      // Simulate end of data at 50 requests
      _hasMoreData = false;
      newData = [];
    }

    if (mounted) {
      setState(() {
        _requestsData.addAll(newData);
        _isLoading = false;
      });
    }
  }

  void _handleNotifications() {
    context.pushNamed('notifications');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _requestsData = _generateMockData(0, 10);
        _hasMoreData = true;
        _isLoading = false;
      });

      context.showSuccessSnackBar('Đã cập nhật danh sách yêu cầu');
    }
  }

  void _onRequestTap(Map<String, dynamic> request) {
    // Navigate to request detail screen
    context.pushNamed('request-detail', pathParameters: {'id': request['id']});
  }

  // Filter requests based on current tab
  List<Map<String, dynamic>> get _filteredRequests {
    final currentTab = _tabController.index;

    return _requestsData.where((request) {
      final requestType = request['requestType'] as int;

      if (currentTab == 0) {
        // Sent items tab: types 0 (Gửi đồ cũ) and 2 (Gửi đồ thất lạc)
        return requestType == 0 || requestType == 2;
      } else {
        // Received items tab: types 1 (Nhận đồ cũ) and 3 (Nhận đồ thất lạc)
        return requestType == 1 || requestType == 3;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final filteredRequests = _filteredRequests;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Danh sách yêu cầu',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        notificationCount: 3,
        onNotificationTap: _handleNotifications,
        // additionalActions: [
        //   IconButton(
        //     onPressed: _handleRefresh,
        //     icon: const Icon(Icons.refresh, color: Colors.white),
        //     tooltip: 'Làm mới',
        //   ),
        // ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    // Reset pagination when switching tabs
                    _hasMoreData = true;
                  });
                },
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_outlined, size: isTablet ? 20 : 18),
                        // SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'Món đồ gửi',
                          style: TextStyle(fontSize: isTablet ? 14 : 12),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_outlined, size: isTablet ? 20 : 18),
                        // SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'Món đồ nhận',
                          style: TextStyle(fontSize: isTablet ? 14 : 12),
                        ),
                      ],
                    ),
                  ),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: theme.hintColor,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 8 : 4,
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sent Items Tab
                  _buildTabContent(
                    filteredRequests,
                    isTablet,
                    theme,
                    colorScheme,
                  ),
                  // Received Items Tab
                  _buildTabContent(
                    filteredRequests,
                    isTablet,
                    theme,
                    colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<Map<String, dynamic>> requests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with count
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 24,
                isTablet ? 24 : 20,
                isTablet ? 32 : 24,
                isTablet ? 16 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: colorScheme.primary,
                        size: isTablet ? 28 : 24,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        _tabController.index == 0
                            ? 'Món đồ đã gửi'
                            : 'Món đồ đã nhận',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 8,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${requests.length} yêu cầu',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Requests List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            sliver:
                requests.isEmpty && !_isLoading
                    ? SliverToBoxAdapter(
                      child: _buildEmptyState(isTablet, theme),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < requests.length) {
                            return _buildRequestItem(
                              requests[index],
                              isTablet,
                              theme,
                              colorScheme,
                            );
                          } else if (_isLoading) {
                            return _buildLoadingItem(isTablet, colorScheme);
                          } else if (!_hasMoreData) {
                            return _buildEndOfListItem(isTablet, theme);
                          }
                          return null;
                        },
                        childCount:
                            requests.length +
                            (_isLoading ? 1 : 0) +
                            (!_hasMoreData && requests.isNotEmpty ? 1 : 0),
                      ),
                    ),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 32 : 24)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(
    Map<String, dynamic> request,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final requestType = request['requestType'] as int;
    final status = request['status'] as int;
    final appointmentTime = request['appointmentTime'] as DateTime;
    final createdAt = request['createdAt'] as DateTime;

    return GestureDetector(
      onTap: () => _onRequestTap(request),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                statusColors[status]?.withOpacity(0.3) ??
                colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Type Icon
                Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcons[requestType] ?? Icons.help_outline,
                    size: isTablet ? 20 : 18,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),

                // Type and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requestTypes[requestType] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              statusColors[status]?.withOpacity(0.1) ??
                              colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          requestStatuses[status] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 9,
                            fontWeight: FontWeight.w600,
                            color: statusColors[status] ?? theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Created time
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Item name
            Text(
              request['itemName'],
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),

            // Description
            Text(
              request['description'],
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: theme.hintColor,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isTablet ? 12 : 10),

            // Location and Time
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: isTablet ? 16 : 14,
                        color: Colors.red.shade400,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Expanded(
                        child: Text(
                          request['location'],
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: theme.hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isTablet ? 16 : 14,
                      color: Colors.blue.shade400,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      _formatDateTime(appointmentTime),
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingItem(bool isTablet, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 36 : 30,
                height: isTablet ? 36 : 30,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: isTablet ? 14 : 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Container(
                      width: 80,
                      height: isTablet ? 12 : 10,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Container(
            width: double.infinity,
            height: isTablet ? 16 : 14,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Container(
            width: double.infinity,
            height: isTablet ? 14 : 12,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, ThemeData theme) {
    final currentTab = _tabController.index;
    final tabTitle = currentTab == 0 ? 'món đồ gửi' : 'món đồ nhận';

    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            currentTab == 0 ? Icons.upload_outlined : Icons.download_outlined,
            size: isTablet ? 80 : 64,
            color: theme.hintColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Không có $tabTitle nào',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Hãy tạo yêu cầu đầu tiên của bạn',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create request screen
              context.pushNamed('create-request');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Tạo yêu cầu mới',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfListItem(bool isTablet, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: isTablet ? 48 : 40,
            color: theme.hintColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Đã hiển thị tất cả yêu cầu',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Bạn đã xem hết ${_filteredRequests.length} yêu cầu',
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: theme.hintColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeString =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (targetDate == today) {
      return 'Hôm nay $timeString';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Ngày mai $timeString';
    } else if (targetDate.isAfter(today) &&
        targetDate.isBefore(today.add(const Duration(days: 7)))) {
      const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      return '${weekdays[targetDate.weekday % 7]} $timeString';
    } else {
      return '${targetDate.day}/${targetDate.month} $timeString';
    }
  }
}
