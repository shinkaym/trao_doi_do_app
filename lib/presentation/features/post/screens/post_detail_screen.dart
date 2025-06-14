import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/data/models/others_model.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/data/models/response/post_response_model.dart';

class PostDetailScreen extends HookConsumerWidget {
  final String postSlug;

  const PostDetailScreen({super.key, required this.postSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks
    final pageController = usePageController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    // State
    final currentImageIndex = useState(0);
    final isBookmarked = useState(false);
    final showFullContent = useState(false);

    // Provider state
    final postDetailState = ref.watch(postDetailProvider);
    final authState = ref.watch(authProvider);
    final interestState = ref.watch(interestProvider);

    // Load post detail on first build
    useEffect(() {
      Future.microtask(() {
        ref.read(postDetailProvider.notifier).getPostDetail(postSlug);
      });
      return () {
        ref.read(postDetailProvider.notifier).clearPost();
      };
    }, [postSlug]);

    // Animation trigger when post is loaded
    useEffect(() {
      if (postDetailState.post != null && !postDetailState.isLoading) {
        animationController.forward();
      }
      return null;
    }, [postDetailState.post, postDetailState.isLoading]);

    // Helper functions to check interest status
    bool isUserInterested(List<InterestModel> interests, int? userID) {
      if (userID == null) return false;
      return interests.any((interest) => interest.userID == userID);
    }

    // Event handlers
    void handleBookmark() {
      isBookmarked.value = !isBookmarked.value;
      if (isBookmarked.value) {
        context.showSuccessSnackBar('Đã lưu bài đăng');
      } else {
        context.showWarningSnackBar('Đã bỏ lưu bài đăng');
      }
    }

    void handleInterest() async {
      final post = postDetailState.post;
      final currentUser = authState.user;

      if (post == null || currentUser == null) {
        context.showErrorSnackBar('Vui lòng đăng nhập để quan tâm bài đăng');
        return;
      }

      if (!interestState.isLoading) {
        // Kiểm tra trạng thái hiện tại của user trong danh sách interests
        final userInterested = isUserInterested(post.interests, currentUser.id);

        // Xác định action dựa trên trạng thái hiện tại
        final action =
            userInterested ? InterestAction.cancel : InterestAction.create;

        // Gọi API toggle interest với action đã xác định
        await ref
            .read(interestProvider.notifier)
            .toggleInterest(post.id!, action);

        final updatedState = ref.read(interestProvider);

        if (updatedState.result?.message != null) {
          HapticFeedback.lightImpact();

          // Reload post detail để cập nhật danh sách interests
          ref.read(postDetailProvider.notifier).getPostDetail(postSlug);

          // Xóa message để lần sau không hiển thị lại
          ref.read(interestProvider.notifier).clearMessages();
        } else if (updatedState.failure != null) {
          context.showErrorSnackBar(updatedState.failure!.message);
          ref.read(interestProvider.notifier).clearMessages();
        }
      }
    }

    void handleShare() {
      context.showInfoSnackBar('Đã sao chép link bài đăng');
    }

    // UI
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Loading state
    if (postDetailState.isLoading && postDetailState.post == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Chi tiết bài đăng',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (postDetailState.failure != null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Chi tiết bài đăng',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                postDetailState.failure!.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(postDetailProvider.notifier).getPostDetail(postSlug);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // No post found
    if (postDetailState.post == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Chi tiết bài đăng',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: Text('Không tìm thấy bài đăng')),
      );
    }

    final post = postDetailState.post!;
    final userInterested = isUserInterested(post.interests, authState.user?.id);
    final interestCount = post.interests.length;

    final images = post.images.isNotEmpty ? post.images : [''];

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar with images
            SliverAppBar(
              expandedHeight: isTablet ? 450 : 350, // Tăng chiều cao
              pinned: true,
              backgroundColor: colorScheme.primary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Tăng độ trong suốt
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: handleShare,
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: handleBookmark,
                    icon: Icon(
                      isBookmarked.value
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: isBookmarked.value ? Colors.amber : Colors.white,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(
                  images,
                  pageController,
                  currentImageIndex,
                ),
              ),
            ),
            // Post Content
            SliverToBoxAdapter(
              child: _buildPostContent(
                post,
                isTablet,
                theme,
                colorScheme,
                showFullContent,
                userInterested,
                interestCount,
                handleInterest,
                ref,
              ),
            ),

            // Items section (if available)
            if (post.items.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildItemsSection(
                  post.items,
                  isTablet,
                  theme,
                  colorScheme,
                ),
              ),

            // Interests section (if available) - UPDATED
            if (post.interests.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildInterestsSection(
                  post.interests,
                  isTablet,
                  theme,
                  colorScheme,
                ),
              ),

            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: isTablet ? 32 : 24)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(
        isTablet,
        theme,
        colorScheme,
        userInterested,
        interestCount,
        handleInterest,
        handleShare,
        ref,
      ),
    );
  }

  // Image Gallery Widget
  Widget _buildImageGallery(
    List<String> images,
    PageController pageController,
    ValueNotifier<int> currentImageIndex,
  ) {
    return Stack(
      children: [
        // Image Gallery
        PageView.builder(
          controller: pageController,
          onPageChanged: (index) {
            currentImageIndex.value = index;
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return _buildBase64Image(images[index]);
          },
        ),

        // Image Counter
        if (images.length > 1)
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
                '${currentImageIndex.value + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Image Dots Indicator
        // Thay thế dots indicator hiện tại
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...images.asMap().entries.map((entry) {
                      final isActive = currentImageIndex.value == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color:
                              isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Post Content Widget
  Widget _buildPostContent(
    PostDetailModel post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    ValueNotifier<bool> showFullContent,
    bool userInterested,
    int interestCount,
    VoidCallback onInterest,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(post, isTablet, theme, colorScheme),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Title
          Text(
            post.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Post Content
          _buildPostContentText(post, isTablet, theme, showFullContent),

          SizedBox(height: isTablet ? 20 : 16),

          // Post Details based on type
          _buildPostDetailsByType(post, isTablet, theme, colorScheme),

          // Tags
          if (post.tags.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildTagsSection(post.tags, isTablet, theme, colorScheme),
          ],

          SizedBox(height: isTablet ? 20 : 16),

          // Action Buttons
        ],
      ),
    );
  }

  Widget _buildAvatar(PostDetailModel post, bool isTablet, ThemeData theme) {
    final radius = isTablet ? 24.0 : 20.0;

    if (post.authorAvatar != null && post.authorAvatar!.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(post.authorAvatar!);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
        );
      }
    }

    // Fallback về icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary,
      child: Icon(Icons.person, color: Colors.white, size: isTablet ? 18 : 16),
    );
  }

  Widget _buildPostHeader(
    PostDetailModel post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Author Avatar
        _buildAvatar(post, isTablet, theme),
        SizedBox(width: isTablet ? 16 : 12),

        // Author Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName ?? 'Người dùng',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Post Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CreatePostType.fromValue(post.type).color().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            CreatePostType.fromValue(post.type).label(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CreatePostType.fromValue(post.type).color(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContentText(
    PostDetailModel post,
    bool isTablet,
    ThemeData theme,
    ValueNotifier<bool> showFullContent,
  ) {
    final content = post.description;
    final shouldTruncate = content.length > 300 && !showFullContent.value;
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
              showFullContent.value = true;
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

  Widget _buildPostDetailsByType(
    PostDetailModel post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Parse info JSON
    Map<String, dynamic> info = {};
    try {
      if (post.info.isNotEmpty && post.info != '{}') {
        info = jsonDecode(post.info);
      }
    } catch (e) {
      // Handle JSON parse error
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Type-specific details
          if (post.type == 2) ...[
            // Found Item - show found location and date
            if (info['foundLocation'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Nơi nhặt được',
                info['foundLocation'],
                theme,
              ),
            if (info['foundDate'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Thời gian nhặt được',
                _formatDate(info['foundDate']),
                theme,
              ),
            ],
          ] else if (post.type == 3) ...[
            // Find Lost - show lost location, date, reward, category
            if (info['lostLocation'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Nơi mất',
                info['lostLocation'],
                theme,
              ),
            if (info['lostDate'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Thời gian mất',
                _formatDate(info['lostDate']),
                theme,
              ),
            ],
            if (info['reward'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.card_giftcard,
                'Phần thưởng',
                '${info['reward']}',
                theme,
              ),
            ],
            if (info['category'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.category,
                'Loại đồ vật',
                info['category'],
                theme,
              ),
            ],
          ],

          // Common details
          if (post.createdAt != null) ...[
            if (post.type == 2 || post.type == 3) const SizedBox(height: 12),
            _buildDetailRow(
              Icons.schedule,
              'Thời gian đăng',
              TimeUtils.formatAbsolute(post.createdAt!),
              theme,
            ),
          ],
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

  Widget _buildTagsSection(
    List<String> tags,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemsSection(
    List<dynamic> items,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đồ vật',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...items.map(
            (item) => _buildItemCard(item, isTablet, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    ItemDetailModel item,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Item Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  item.image.isNotEmpty
                      ? _buildBase64Image(item.image)
                      : Icon(
                        Icons.inventory_2,
                        color: colorScheme.primary,
                        size: 20,
                      ),
            ),
          ),

          const SizedBox(width: 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.currentQuantity}/${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            width: 6,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor(item.currentQuantity, item.quantity),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int current, int total) {
    if (total == 0) return Colors.grey;

    double percentage = current / total;

    if (percentage >= 0.7) {
      return Colors.green;
    } else if (percentage >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // UPDATED: New interests section design
  Widget _buildInterestsSection(
    List<InterestModel> interests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(interests, isTablet, theme, colorScheme),
          const SizedBox(height: 16),
          interests.isEmpty
              ? _buildEmptyState(theme, colorScheme, isTablet)
              : _buildInterestsList(interests, isTablet, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    List<InterestModel> interests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.05), Colors.pink.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.red,
              size: isTablet ? 20 : 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Người quan tâm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (interests.isNotEmpty)
                  Text(
                    _getInterestText(interests.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isTablet ? 13 : 12,
                    ),
                  ),
              ],
            ),
          ),
          if (interests.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 6 : 5,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: isTablet ? 14 : 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${interests.length}',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: isTablet ? 32 : 28,
              color: colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có ai quan tâm',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy chia sẻ bài đăng để thu hút sự quan tâm',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsList(
    List<InterestModel> interests,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Hiển thị tối đa 6 người đầu tiên, có thể mở rộng
    final displayCount = interests.length > 6 ? 6 : interests.length;
    final hasMore = interests.length > 6;

    return Column(
      children: [
        Container(
          height: isTablet ? 110 : 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: displayCount + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (hasMore && index == displayCount) {
                return _buildMoreUsersIndicator(
                  interests.length - displayCount,
                  isTablet,
                  theme,
                  colorScheme,
                );
              }

              return _buildUserCard(
                interests[index],
                isTablet,
                theme,
                colorScheme,
              );
            },
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed:
                () => _showAllInterestedUsers(interests, theme, colorScheme),
            icon: Icon(Icons.expand_more, size: isTablet ? 18 : 16),
            label: Text(
              'Xem tất cả ${interests.length} người',
              style: TextStyle(fontSize: isTablet ? 14 : 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUserCard(
    InterestModel interest,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => _onUserTap(interest),
      child: Container(
        width: isTablet ? 80 : 70,
        child: Column(
          children: [
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildUserAvatar(interest, isTablet, theme, colorScheme),
            ),
            const SizedBox(height: 8),
            Text(
              _truncateUserName(interest.userName, 12),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              width: isTablet ? 20 : 16,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreUsersIndicator(
    int moreCount,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => _showAllInterestedUsers([], theme, colorScheme),
      child: Container(
        width: isTablet ? 80 : 70,
        child: Column(
          children: [
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$moreCount',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
    InterestModel interest,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final radius = isTablet ? 24.0 : 20.0;

    if (interest.userAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.grey[200],
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        interest.userName.isNotEmpty ? interest.userName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  // Helper methods
  String _getInterestText(int count) {
    if (count == 1) return '1 người đã quan tâm';
    return '$count người đã quan tâm';
  }

  String _truncateUserName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  void _onUserTap(InterestModel interest) {}

  void _showAllInterestedUsers(
    List<InterestModel> interests,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {}

  Widget _buildBottomActionBar(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    bool userInterested,
    int interestCount,
    VoidCallback onInterest,
    VoidCallback onShare,
    WidgetRef ref,
  ) {
    final interestState = ref.watch(interestProvider);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Share Button
            OutlinedButton.icon(
              onPressed: onShare,
              icon: Icon(Icons.share_outlined, size: isTablet ? 18 : 16),
              label: Text(
                'Chia sẻ',
                style: TextStyle(fontSize: isTablet ? 14 : 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 10,
                ),
              ),
            ),

            SizedBox(width: isTablet ? 12 : 8),

            // Interest Button (Expanded) with loading state
            Expanded(
              child: ElevatedButton(
                onPressed: interestState.isLoading ? null : onInterest,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  backgroundColor:
                      userInterested ? Colors.red : colorScheme.primary,
                  disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (interestState.isLoading)
                      SizedBox(
                        width: isTablet ? 16 : 14,
                        height: isTablet ? 16 : 14,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      Icon(
                        userInterested ? Icons.favorite : Icons.favorite_border,
                        size: isTablet ? 18 : 16,
                        color: Colors.white,
                      ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Text(
                      interestState.isLoading
                          ? 'Đang xử lý...'
                          : userInterested
                          ? 'Đã quan tâm ($interestCount)'
                          : 'Quan tâm ($interestCount)',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBase64Image(String base64String) {
    if (base64String.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(base64String);

      if (imageBytes != null) {
        return InteractiveViewer(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );
      }
    }

    // Fallback về broken image nếu không có ảnh hoặc có lỗi decode
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Không rõ';

    try {
      final date = DateTime.parse(dateString);
      return TimeUtils.formatTimeAgo(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}
