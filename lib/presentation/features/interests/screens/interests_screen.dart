import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

// Model cho người quan tâm
class InterestedUser {
  final String id;
  final String interestId; // Thêm dòng này
  final String name;
  final String avatar;
  final DateTime interestedAt;

  const InterestedUser({
    required this.id,
    required this.interestId, // Thêm dòng này
    required this.name,
    required this.avatar,
    required this.interestedAt,
  });
}

// Model cho bài đăng quan tâm
class InterestedPost {
  final String id;
  final String interestId; // Thêm dòng này
  final String title;
  final String author;
  final String authorId;
  final String authorAvatar;
  final String type;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime interestedAt;
  final String? thumbnail;

  const InterestedPost({
    required this.id,
    required this.interestId, // Thêm dòng này
    required this.title,
    required this.author,
    required this.authorId,
    required this.authorAvatar,
    required this.type,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.interestedAt,
    this.thumbnail,
  });
}

// Model cho bài đăng được quan tâm
class PostWithInterests {
  final String id;
  final String title;
  final String type;
  final String location;
  final String status;
  final DateTime createdAt;
  final List<InterestedUser> interestedUsers;
  final String? thumbnail;

  const PostWithInterests({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.interestedUsers,
    this.thumbnail,
  });
}

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data cho bài đăng mà người dùng đã quan tâm
  final List<InterestedPost> _interestedPosts = [
    InterestedPost(
      id: '1',
      interestId: 'interest_1',
      title: 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
      author: 'Nguyễn Văn A',
      authorId: 'user1',
      authorAvatar: '',
      type: 'findLost',
      location: 'Quận 1, TP.HCM',
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      interestedAt: DateTime.now().subtract(const Duration(hours: 1)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
    ),
    InterestedPost(
      id: '2',
      interestId: 'interest_2',
      title: 'Nhặt được điện thoại iPhone tại công viên Tao Đàn',
      author: 'Trần Thị B',
      authorId: 'user2',
      authorAvatar: '',
      type: 'foundItem',
      location: 'Quận 1, TP.HCM',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      interestedAt: DateTime.now().subtract(const Duration(hours: 3)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
    ),
    InterestedPost(
      id: '3',
      interestId: 'interest_3',
      title: 'Tặng bộ sách giáo khoa lớp 12 đầy đủ',
      author: 'Lê Văn C',
      authorId: 'user3',
      authorAvatar: '',
      type: 'giveAway',
      location: 'Quận 3, TP.HCM',
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      interestedAt: DateTime.now().subtract(const Duration(hours: 6)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
    ),
    InterestedPost(
      id: '4',
      interestId: 'interest_4',
      title: 'Tặng xe đạp cũ còn dùng được',
      author: 'Võ Văn F',
      authorId: 'user4',
      authorAvatar: '',
      type: 'giveAway',
      location: 'Quận 10, TP.HCM',
      status: 'reserved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      interestedAt: DateTime.now().subtract(const Duration(hours: 12)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
    ),
  ];

  // Mock data cho bài đăng của người dùng được quan tâm
  final List<PostWithInterests> _postsWithInterests = [
    PostWithInterests(
      id: '5',
      title: 'Tìm chú chó Golden Retriever bị lạc',
      type: 'findLost',
      location: 'Quận 7, TP.HCM',
      status: 'urgent',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
      interestedUsers: [
        InterestedUser(
          id: 'user5',
          interestId: 'interest_5',
          name: 'Phạm Văn D',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        InterestedUser(
          id: 'user6',
          interestId: 'interest_6',
          name: 'Hoàng Thị E',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        InterestedUser(
          id: 'user7',
          interestId: 'interest_7',
          name: 'Đặng Văn G',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
    PostWithInterests(
      id: '6',
      title: 'Tặng máy tính cũ còn hoạt động tốt',
      type: 'giveAway',
      location: 'Quận 5, TP.HCM',
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
      interestedUsers: [
        InterestedUser(
          id: 'user8',
          interestId: 'interest_8',
          name: 'Nguyễn Thị H',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        InterestedUser(
          id: 'user9',
          interestId: 'interest_9',
          name: 'Lê Văn I',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
    ),
    PostWithInterests(
      id: '7',
      title: 'Nhặt được chìa khóa tại trường đại học',
      type: 'foundItem',
      location: 'Quận Thủ Đức, TP.HCM',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      thumbnail: 'https://dummyimage.com/600x400/000/fff',
      interestedUsers: [
        InterestedUser(
          id: 'user10',
          interestId: 'interest_10',
          name: 'Trần Văn K',
          avatar: '',
          interestedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handlePostTap(String postId) {
    context.pushNamed('post-detail', pathParameters: {'id': postId});
  }

  void _handleChatTap(String interestId) {
    // Điều hướng đến màn hình chat
    context.pushNamed(
      'interest-chat',
      pathParameters: {'interestId': interestId},
    );
  }

  void _handleRemoveInterest(String postId) {
    setState(() {
      _interestedPosts.removeWhere((post) => post.id == postId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã bỏ quan tâm bài đăng'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật danh sách'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleNotifications() {
    context.pushNamed('notifications');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Quan tâm',
        notificationCount: 5,
        onNotificationTap: _handleNotifications,
        showBackButton: false,
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
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_outline),
                        SizedBox(width: isTablet ? 8 : 6),
                        const Text('Quan tâm'),
                        if (_interestedPosts.isNotEmpty) ...[
                          SizedBox(width: isTablet ? 8 : 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6,
                              vertical: isTablet ? 2 : 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_interestedPosts.length}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        SizedBox(width: isTablet ? 8 : 6),
                        const Text('Được quan tâm'),
                        if (_postsWithInterests.isNotEmpty) ...[
                          SizedBox(width: isTablet ? 8 : 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6,
                              vertical: isTablet ? 2 : 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_postsWithInterests.fold<int>(0, (sum, post) => sum + post.interestedUsers.length)}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: theme.hintColor,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
              ),
            ),

            // Tab Views
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Bài đăng đã quan tâm
                    _buildInterestedPostsTab(isTablet, theme, colorScheme),

                    // Tab 2: Bài đăng được quan tâm
                    _buildPostsWithInterestsTab(isTablet, theme, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestedPostsTab(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_interestedPosts.isEmpty) {
      return _buildEmptyState(
        isTablet,
        theme,
        colorScheme,
        'Chưa có bài đăng quan tâm',
        'Khám phá và quan tâm các bài đăng thú vị',
        Icons.favorite_border,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: isTablet ? 24 : 16,
      ),
      itemCount: _interestedPosts.length,
      itemBuilder: (context, index) {
        final post = _interestedPosts[index];
        return _buildInterestedPostCard(post, isTablet, theme, colorScheme);
      },
    );
  }

  Widget _buildPostsWithInterestsTab(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_postsWithInterests.isEmpty) {
      return _buildEmptyState(
        isTablet,
        theme,
        colorScheme,
        'Chưa có bài đăng được quan tâm',
        'Tạo bài đăng để nhận được sự quan tâm từ cộng đồng',
        Icons.post_add,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: isTablet ? 24 : 16,
      ),
      itemCount: _postsWithInterests.length,
      itemBuilder: (context, index) {
        final post = _postsWithInterests[index];
        return _buildPostWithInterestsCard(post, isTablet, theme, colorScheme);
      },
    );
  }

  Widget _buildInterestedPostCard(
    InterestedPost post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      post.thumbnail != null
                          ? Image.network(
                            post.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildThumbnailPlaceholder(
                                post.type,
                                isTablet,
                                theme,
                              );
                            },
                          )
                          : _buildThumbnailPlaceholder(
                            post.type,
                            isTablet,
                            theme,
                          ),
                ),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and Status
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(post.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeLabel(post.type),
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 10,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(post.type),
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              post.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusText(post.status),
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(post.status),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 8 : 6),

                    // Title
                    Text(
                      post.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 15 : 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isTablet ? 8 : 6),

                    // Author and Location
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                        SizedBox(width: isTablet ? 4 : 2),
                        Expanded(
                          child: Text(
                            post.author,
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: theme.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 4 : 2),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                        SizedBox(width: isTablet ? 4 : 2),
                        Expanded(
                          child: Text(
                            post.location,
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: theme.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 8 : 6),

                    // Interested time
                    Text(
                      'Quan tâm ${_formatTimeAgo(post.interestedAt)}',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  // View post button
                  IconButton(
                    onPressed: () => _handlePostTap(post.id),
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: 'Xem bài đăng',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      minimumSize: Size(isTablet ? 40 : 32, isTablet ? 40 : 32),
                    ),
                  ),

                  SizedBox(height: isTablet ? 8 : 6),

                  // Chat button
                  IconButton(
                    onPressed: () => _handleChatTap(post.interestId),
                    icon: const Icon(Icons.chat_outlined),
                    tooltip: 'Nhắn tin',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      minimumSize: Size(isTablet ? 40 : 32, isTablet ? 40 : 32),
                    ),
                  ),

                  SizedBox(height: isTablet ? 8 : 6),

                  // Remove interest button
                  IconButton(
                    onPressed: () => _handleRemoveInterest(post.id),
                    icon: const Icon(Icons.favorite),
                    tooltip: 'Bỏ quan tâm',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      minimumSize: Size(isTablet ? 40 : 32, isTablet ? 40 : 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostWithInterestsCard(
    PostWithInterests post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Thumbnail
                  Container(
                    width: isTablet ? 60 : 48,
                    height: isTablet ? 60 : 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceVariant,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          post.thumbnail != null
                              ? Image.network(
                                post.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildThumbnailPlaceholder(
                                    post.type,
                                    isTablet,
                                    theme,
                                  );
                                },
                              )
                              : _buildThumbnailPlaceholder(
                                post.type,
                                isTablet,
                                theme,
                              ),
                    ),
                  ),

                  SizedBox(width: isTablet ? 12 : 8),

                  // Post info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type and Status
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 8 : 6,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(
                                  post.type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getTypeLabel(post.type),
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(post.type),
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 8 : 6,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  post.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(post.status),
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(post.status),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 6 : 4),

                        // Title
                        Text(
                          post.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 15 : 14,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isTablet ? 4 : 2),

                        // Location and created time
                        Text(
                          '${post.location} • ${_formatTimeAgo(post.createdAt)}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // View post button
                  IconButton(
                    onPressed: () => _handlePostTap(post.id),
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: 'Xem bài đăng',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      minimumSize: Size(isTablet ? 40 : 32, isTablet ? 40 : 32),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 12 : 8),

              // Interested users
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: isTablet ? 16 : 14,
                    color: Colors.red,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    '${post.interestedUsers.length} người quan tâm',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 8 : 6),

              // List of interested users
              ...post.interestedUsers.map(
                (user) => Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // User avatar
                      CircleAvatar(
                        radius: isTablet ? 16 : 14,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child:
                            user.avatar.isNotEmpty
                                ? ClipOval(
                                  child: Image.network(
                                    user.avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: isTablet ? 16 : 14,
                                        color: colorScheme.primary,
                                      );
                                    },
                                  ),
                                )
                                : Icon(
                                  Icons.person,
                                  size: isTablet ? 16 : 14,
                                  color: colorScheme.primary,
                                ),
                      ),

                      SizedBox(width: isTablet ? 12 : 8),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Quan tâm ${_formatTimeAgo(user.interestedAt)}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chat button
                      IconButton(
                        onPressed: () => _handleChatTap(user.interestId),
                        icon: const Icon(Icons.chat_outlined),
                        tooltip: 'Nhắn tin với ${user.name}',
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                          minimumSize: Size(
                            isTablet ? 36 : 28,
                            isTablet ? 36 : 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isTablet ? 48 : 40,
                color: colorScheme.outline,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 20 : 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(
    String type,
    bool isTablet,
    ThemeData theme,
  ) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'findLost':
        iconData = Icons.search;
        iconColor = Colors.orange;
        break;
      case 'foundItem':
        iconData = Icons.visibility;
        iconColor = Colors.green;
        break;
      case 'giveAway':
        iconData = Icons.card_giftcard;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.article;
        iconColor = theme.hintColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, size: isTablet ? 32 : 24, color: iconColor),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'findLost':
        return 'Tìm đồ';
      case 'foundItem':
        return 'Nhặt được';
      case 'giveAway':
        return 'Tặng miễn phí';
      default:
        return 'Khác';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'findLost':
        return Colors.orange;
      case 'foundItem':
        return Colors.green;
      case 'giveAway':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang tìm';
      case 'pending':
        return 'Chờ xử lý';
      case 'available':
        return 'Còn tặng';
      case 'reserved':
        return 'Đã đặt';
      case 'urgent':
        return 'Khẩn cấp';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'available':
        return Colors.blue;
      case 'reserved':
        return Colors.purple;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}
