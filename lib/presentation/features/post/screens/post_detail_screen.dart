import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final PageController _imagePageController = PageController();

  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _showFullContent = false;
  int _currentImageIndex = 0;
  int _likeCount = 0;

  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _relatedPosts = [];

  // Mock data cho bài đăng chi tiết
  final Map<String, dynamic> _mockPost = {
    'id': '1',
    'title': 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
    'content': '''Xin chào mọi người,

Mình bị mất chiếc ví da màu nâu hôm qua (ngày 30/05) khoảng 14h30 tại khu vực quận 1, gần chợ Bến Thành. Cụ thể là trên đường Lê Lợi, từ khách sạn Rex đến chợ Bến Thành.

Chi tiết về chiếc ví:
- Ví da thật màu nâu, thương hiệu local
- Bên trong có CMND (tên Nguyễn Văn A), thẻ ngân hàng Vietcombank và Techcombank
- Khoảng 2 triệu tiền mặt
- Có một tấm ảnh gia đình nhỏ
- Một số thẻ thành viên của các cửa hàng

Đây là những giấy tờ rất quan trọng với mình, đặc biệt là CMND vì mình sắp phải đi công tác. Mình rất mong ai đó nhặt được có thể liên hệ với mình.

Mình cam kết sẽ có hậu tạ xứng đáng cho người tìm thấy và trả lại ví. Xin cảm ơn mọi người rất nhiều!''',
    'type': 'findLost',
    'location': 'Quận 1, TP.HCM',
    'detailedLocation': 'Đường Lê Lợi, từ khách sạn Rex đến chợ Bến Thành',
    'images': [
      'https://dummyimage.com/800x600/8B4513/FFFFFF&text=Ví+Da+Nâu+Mặt+Trước',
      'https://dummyimage.com/800x600/654321/FFFFFF&text=Ví+Da+Nâu+Mặt+Sau',
      'https://dummyimage.com/800x600/A0522D/FFFFFF&text=Bên+Trong+Ví',
    ],
    'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
    'updatedAt': DateTime.now().subtract(const Duration(minutes: 30)),
    'status': 'urgent',
    'author': 'Nguyễn Văn A',
    'authorID': 'user_001',
    'authorAvatar': 'https://dummyimage.com/100x100/4A90E2/FFFFFF&text=A',
    'authorPhone': '0901234567',
    'authorEmail': 'nguyenvana@email.com',
    'rewardOffered': '500,000đ',
    'category': 'Phụ kiện',
    'condition': null,
    'tags': ['ví da', 'quận 1', 'lê lợi', 'cmnd', 'khẩn cấp'],
    'viewCount': 156,
    'shareCount': 8,
    'reportCount': 0,
    'isVerified': true,
    'priority': 'high',
  };

  // Mock related posts
  final List<Map<String, dynamic>> _mockRelatedPosts = [
    {
      'id': '2',
      'title': 'Nhặt được điện thoại iPhone tại công viên Tao Đàn',
      'type': 'foundItem',
      'location': 'Quận 1, TP.HCM',
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
      'author': 'Trần Thị B',
      'image': 'https://dummyimage.com/300x200/3498DB/FFFFFF&text=iPhone',
    },
    {
      'id': '5',
      'title': 'Tìm chú chó Golden Retriever bị lạc',
      'type': 'findLost',
      'location': 'Quận 7, TP.HCM',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'author': 'Hoàng Thị E',
      'image': 'https://dummyimage.com/300x200/F39C12/FFFFFF&text=Golden',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _post = _mockPost;
      _relatedPosts = _mockRelatedPosts;
      _likeCount = 24;
      _isLoading = false;
    });
  }

  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      context.showSuccessSnackBar('Đã lưu bài đăng');
    } else {
      context.showWarningSnackBar('Đã bỏ lưu bài đăng');
    }
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    if (_isLiked) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleShare() {
    // Implement share functionality
    context.showInfoSnackBar('Đã sao chép link bài đăng');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: Text('Không tìm thấy bài đăng')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with image
          _buildSliverAppBar(isTablet, theme, colorScheme),

          // Post Content
          SliverToBoxAdapter(
            child: _buildPostContent(isTablet, theme, colorScheme),
          ),

          // Related Posts
          SliverToBoxAdapter(
            child: _buildRelatedPostsSection(isTablet, theme, colorScheme),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 32 : 24)),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(isTablet, theme, colorScheme),
    );
  }

  Widget _buildSliverAppBar(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hasImages =
        _post!['images'] != null && (_post!['images'] as List).isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasImages ? (isTablet ? 400 : 300) : 120,
      floating: false,
      pinned: true,
      backgroundColor: hasImages ? colorScheme.primary : colorScheme.surface,
      foregroundColor: hasImages ? Colors.white : colorScheme.onSurface,
      leading:
          hasImages
              ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              )
              : null,
      actions:
          hasImages
              ? [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _handleShare,
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _handleBookmark,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? Colors.amber : Colors.white,
                    ),
                  ),
                ),
              ]
              : [
                IconButton(
                  onPressed: _handleBookmark,
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? Colors.amber : null,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.share),
                            title: Text('Chia sẻ'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: ListTile(
                            leading: Icon(Icons.report, color: Colors.red),
                            title: Text(
                              'Báo cáo',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        _handleShare();
                        break;
                    }
                  },
                ),
              ],
      flexibleSpace: FlexibleSpaceBar(
        background:
            hasImages ? _buildImageGallery(isTablet, colorScheme) : null,
      ),
    );
  }

  Widget _buildImageGallery(bool isTablet, ColorScheme colorScheme) {
    final images = _post!['images'] as List;

    return Stack(
      children: [
        // Image Gallery
        PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            );
          },
        ),

        // Image Counter
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Image Dots Indicator
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children:
                  images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentImageIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPostContent(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(isTablet, theme, colorScheme),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Title
          Text(
            _post!['title'],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Post Content
          _buildPostContentText(isTablet, theme),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Details
          _buildPostDetails(isTablet, theme, colorScheme),

          SizedBox(height: isTablet ? 20 : 16),

          // Action Buttons
          _buildActionButtons(isTablet, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPostHeader(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Author Avatar
        CircleAvatar(
          radius: isTablet ? 24 : 20,
          backgroundImage: NetworkImage(_post!['authorAvatar']),
          onBackgroundImageError: (_, __) {},
          child:
              _post!['authorAvatar'] == null
                  ? Icon(Icons.person, size: isTablet ? 24 : 20)
                  : null,
        ),

        SizedBox(width: isTablet ? 16 : 12),

        // Author Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _post!['author'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_post!['isVerified'] == true) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.verified, size: 16, color: Colors.blue),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(_post!['createdAt']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // Post Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPostTypeColor(_post!['type']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPostTypeText(_post!['type']),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getPostTypeColor(_post!['type']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContentText(bool isTablet, ThemeData theme) {
    final content = _post!['content'] as String;
    final shouldTruncate = content.length > 300 && !_showFullContent;
    final displayContent =
        shouldTruncate ? '${content.substring(0, 300)}...' : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayContent,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullContent = true;
              });
            },
            child: Text(
              'Xem thêm',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostDetails(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Location
          _buildDetailRow(
            Icons.location_on,
            'Địa điểm',
            _post!['location'],
            theme,
          ),

          if (_post!['detailedLocation'] != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.place,
              'Chi tiết',
              _post!['detailedLocation'],
              theme,
            ),
          ],

          if (_post!['rewardOffered'] != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.card_giftcard,
              'Hậu tạ',
              _post!['rewardOffered'],
              theme,
            ),
          ],

          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.category,
            'Danh mục',
            _post!['category'],
            theme,
          ),

          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Cập nhật',
            _formatDateTime(_post!['updatedAt']),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Like Button
        InkWell(
          onTap: _handleLike,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('$_likeCount'),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // View Count
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_outlined, size: 20),
            const SizedBox(width: 4),
            Text('${_post!['viewCount']}'),
          ],
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildRelatedPostsSection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_relatedPosts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bài đăng liên quan',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 20 : 16),

          ..._relatedPosts.map(
            (post) => _buildRelatedPostItem(post, isTablet, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedPostItem(
    Map<String, dynamic> post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to related post
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Post Image
              if (post['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_outlined),
                        ),
                  ),
                ),

              const SizedBox(width: 12),

              // Post Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPostTypeColor(
                              post['type'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPostTypeText(post['type']),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getPostTypeColor(post['type']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post['location'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(post['createdAt']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Like Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleLike,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                ),
                label: Text('Quan tâm ($_likeCount)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Share Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleShare,
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getPostTypeColor(String type) {
    switch (type) {
      case 'findLost':
        return Colors.red;
      case 'foundItem':
        return Colors.green;
      case 'exchange':
        return Colors.blue;
      case 'giveaway':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPostTypeText(String type) {
    switch (type) {
      case 'findLost':
        return 'Tìm kiếm';
      case 'foundItem':
        return 'Nhặt được';
      case 'exchange':
        return 'Trao đổi';
      case 'giveaway':
        return 'Tặng miễn phí';
      default:
        return 'Khác';
    }
  }
}
