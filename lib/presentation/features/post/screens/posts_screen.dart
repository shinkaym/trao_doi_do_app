import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

// Enum cho loại bài đăng
enum PostType {
  all('Tất cả', Icons.view_list),
  findLost('Tìm đồ thất lạc', Icons.search),
  foundItem('Nhặt đồ thất lạc', Icons.help_outline),
  giveAway('Gửi đồ cũ', Icons.volunteer_activism),
  freePost('Bài đăng tự do', Icons.edit_note);

  const PostType(this.label, this.icon);
  final String label;
  final IconData icon;
}

// Enum cho sắp xếp thời gian
enum SortOrder {
  newest('Mới nhất', Icons.arrow_downward),
  oldest('Cũ nhất', Icons.arrow_upward);

  const SortOrder(this.label, this.icon);
  final String label;
  final IconData icon;
}

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLoading = false;
  bool _hasMoreData = true;
  PostType _selectedType = PostType.all;
  SortOrder _selectedSort = SortOrder.newest;
  String _searchQuery = '';

  // Mock data cho danh sách bài đăng
  List<Map<String, dynamic>> _allPosts = [
    {
      'id': '1',
      'title': 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
      'content':
          'Mình bị mất chiếc ví da màu nâu hôm qua tại khu vực quận 1, gần chợ Bến Thành. Ví có chứa CMND và một số giấy tờ quan trọng. Ai nhặt được xin liên hệ mình nhé!',
      'type': 'findLost',
      'location': 'Quận 1, TP.HCM',
      'images': [
        'https://dummyimage.com/600x400/000/fff',
        'https://dummyimage.com/600x400/000/fff',
      ],
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'active',
      'author': 'Nguyễn Văn A',
      'authorAvatar': '',
      'contactInfo': '0901234567',
      'rewardOffered': '500,000đ',
      'category': 'Phụ kiện',
      'tags': ['ví', 'da', 'nâu', 'quận 1', 'chợ bến thành'],
    },
    {
      'id': '2',
      'title': 'Nhặt được điện thoại iPhone tại công viên Tao Đàn',
      'content':
          'Mình vừa nhặt được chiếc iPhone tại công viên Tao Đàn lúc 15h chiều nay. Điện thoại có case màu xanh, còn pin. Chủ nhân liên hệ mình để lấy lại nhé!',
      'type': 'foundItem',
      'location': 'Quận 1, TP.HCM',
      'images': ['https://dummyimage.com/600x400/000/fff'],
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
      'status': 'pending',
      'author': 'Trần Thị B',
      'authorAvatar': '',
      'contactInfo': '0912345678',
      'category': 'Điện tử',
      'tags': ['iphone', 'điện thoại', 'công viên', 'tao đàn', 'case xanh'],
    },
    {
      'id': '3',
      'title': 'Tặng bộ sách giáo khoa lớp 12 đầy đủ',
      'content':
          'Mình có bộ sách giáo khoa lớp 12 đầy đủ các môn, còn rất mới vì ít sử dụng. Muốn tặng cho bạn nào cần. Ưu tiên các bạn có hoàn cảnh khó khăn nhé!',
      'type': 'giveAway',
      'location': 'Quận 3, TP.HCM',
      'images': [
        'https://dummyimage.com/600x400/000/fff',
        'https://dummyimage.com/600x400/000/fff',
        'https://dummyimage.com/600x400/000/fff',
      ],
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
      'status': 'available',
      'author': 'Lê Văn C',
      'authorAvatar': '',
      'contactInfo': '0923456789',
      'category': 'Sách vở',
      'condition': 'Như mới',
      'tags': ['sách', 'giáo khoa', 'lớp 12', 'tặng', 'học tập'],
    },
    {
      'id': '4',
      'title': 'Chia sẻ kinh nghiệm tìm việc làm IT',
      'content':
          'Mình vừa tìm được việc làm developer sau 3 tháng tìm kiếm. Muốn chia sẻ một số kinh nghiệm về cách viết CV, chuẩn bị phỏng vấn và các kỹ năng cần thiết. Ai cần tư vấn có thể inbox mình nhé!',
      'type': 'freePost',
      'location': 'Online',
      'images': [],
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)),
      'status': 'active',
      'author': 'Phạm Văn D',
      'authorAvatar': '',
      'contactInfo': '',
      'category': 'Tư vấn',
      'tags': ['việc làm', 'IT', 'developer', 'CV', 'phỏng vấn', 'kinh nghiệm'],
    },
    {
      'id': '5',
      'title': 'Tìm chú chó Golden Retriever bị lạc',
      'content':
          'Chú chó Golden Retriever tên Lucky của gia đình mình bị lạc từ hôm qua. Chú có đeo vòng cổ màu đỏ, rất thân thiện với người. Ai thấy xin liên hệ gia đình mình. Có hậu tạ!',
      'type': 'findLost',
      'location': 'Quận 7, TP.HCM',
      'images': [
        'https://dummyimage.com/600x400/000/fff',
        'https://dummyimage.com/600x400/000/fff',
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'urgent',
      'author': 'Hoàng Thị E',
      'authorAvatar': '',
      'contactInfo': '0934567890',
      'rewardOffered': '2,000,000đ',
      'category': 'Thú cưng',
      'tags': ['chó', 'golden retriever', 'lucky', 'vòng cổ đỏ', 'thú cưng'],
    },
    {
      'id': '6',
      'title': 'Tặng xe đạp cũ còn dùng được',
      'content':
          'Mình có chiếc xe đạp cũ, phanh và đề đều hoạt động tốt. Do chuyển nhà nên không thể mang theo. Tặng free cho ai cần, chỉ cần đến lấy.',
      'type': 'giveAway',
      'location': 'Quận 10, TP.HCM',
      'images': ['https://dummyimage.com/600x400/000/fff'],
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'reserved',
      'author': 'Võ Văn F',
      'authorAvatar': '',
      'contactInfo': '0945678901',
      'category': 'Phương tiện',
      'condition': 'Khá tốt',
      'tags': ['xe đạp', 'tặng', 'phương tiện', 'phanh', 'đề'],
    },
    {
      'id': '7',
      'title': 'Review quán cà phê mới ở quận 2',
      'content':
          'Mình vừa đi thử quán cà phê mới mở ở quận 2, không gian rất đẹp và yên tĩnh, phù hợp để làm việc. Cà phê ngon, giá cả hợp lý. Recommend cho mọi người!',
      'type': 'freePost',
      'location': 'Quận 2, TP.HCM',
      'images': [],
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'active',
      'author': 'Đặng Thị G',
      'authorAvatar': '',
      'contactInfo': '',
      'category': 'Review',
      'tags': ['cà phê', 'quán', 'quận 2', 'review', 'làm việc', 'yên tĩnh'],
    },
  ];

  List<Map<String, dynamic>> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _filterPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

    await Future.delayed(const Duration(seconds: 1));

    if (_allPosts.length >= 20) {
      _hasMoreData = false;
    } else {
      List<Map<String, dynamic>> newPosts = [];
      for (int i = 1; i <= 5; i++) {
        final postTypes = ['findLost', 'foundItem', 'giveAway', 'freePost'];
        final selectedType = postTypes[(i % 4)];

        newPosts.add({
          'id': '${_allPosts.length + i}',
          'title': 'Bài đăng ${_allPosts.length + i}',
          'content': 'Nội dung bài đăng ${_allPosts.length + i}',
          'type': selectedType,
          'location': 'TP.HCM',
          'images':
              selectedType == 'freePost'
                  ? []
                  : ['https://example.com/image${i}.jpg'],
          'createdAt': DateTime.now().subtract(
            Duration(days: _allPosts.length + i),
          ),
          'status': 'active',
          'author': 'Người dùng ${_allPosts.length + i}',
          'authorAvatar': '',
          'contactInfo': '090123456${i}',
          'category': 'Khác',
          'tags': ['tag${i}', 'khác'],
        });
      }
      _allPosts.addAll(newPosts);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _filterPosts();
    }
  }

  void _filterPosts() {
    List<Map<String, dynamic>> filtered = List.from(_allPosts);

    // Filter by type
    if (_selectedType != PostType.all) {
      filtered =
          filtered.where((post) => post['type'] == _selectedType.name).toList();
    }

    // Enhanced search filtering
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();

      filtered =
          filtered.where((post) {
            bool matches = false;
            matches = _searchInAllFields(post, query);

            return matches;
          }).toList();
    }

    // Enhanced sorting
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case SortOrder.newest:
          return (b['createdAt'] as DateTime).compareTo(
            a['createdAt'] as DateTime,
          );
        case SortOrder.oldest:
          return (a['createdAt'] as DateTime).compareTo(
            b['createdAt'] as DateTime,
          );
      }
    });

    setState(() {
      _filteredPosts = filtered;
    });
  }

  bool _searchInAllFields(Map<String, dynamic> post, String query) {
    final searchFields = [
      post['title'].toString().toLowerCase(),
      post['content'].toString().toLowerCase(),
      post['category'].toString().toLowerCase(),
      post['location'].toString().toLowerCase(),
      post['author'].toString().toLowerCase(),
    ];

    // Tìm kiếm trong tags
    if (post['tags'] != null) {
      searchFields.addAll(
        (post['tags'] as List).map((tag) => tag.toString().toLowerCase()),
      );
    }

    // Tìm kiếm chính xác và tìm kiếm từng từ
    final queryWords =
        query.split(' ').where((word) => word.isNotEmpty).toList();

    return searchFields.any(
      (field) =>
          field.contains(query) ||
          queryWords.every((word) => field.contains(word)),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    _filterPosts();
  }

  void _clearSearch() {
    _searchController.clear();
    _handleSearch('');
    _searchFocusNode.unfocus();
  }

  void _handleTypeFilter(PostType type) {
    setState(() {
      _selectedType = type;
    });
    _filterPosts();
  }

  void _handleSortFilter(SortOrder sort) {
    setState(() {
      _selectedSort = sort;
    });
    _filterPosts();
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
        _isLoading = false;
      });

      context.showSuccessSnackBar('Đã cập nhật danh sách bài đăng');
    }
  }

  void _handlePostTap(Map<String, dynamic> post) {
    context.pushNamed('post-detail', pathParameters: {'id': post['id']});
  }

  void _handleCreatePost() {
    context.pushNamed('create-post');
  }

  bool _hasImages(Map<String, dynamic> post) {
    return post['type'] != 'freePost' &&
        post['images'] != null &&
        (post['images'] as List).isNotEmpty &&
        (post['images'] as List).any((img) => img.toString().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Bảng tin',
        notificationCount: 5,
        onNotificationTap: _handleNotifications,
        showBackButton: false,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              // Enhanced Search and Filter Section
              _buildEnhancedSearchSection(isTablet, theme, colorScheme),

              // Content
              Expanded(
                child:
                    _filteredPosts.isEmpty && !_isLoading
                        ? _buildEmptyState(isTablet, theme, colorScheme)
                        : CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            // Posts List
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32 : 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < _filteredPosts.length) {
                                      return _buildPostCard(
                                        _filteredPosts[index],
                                        isTablet,
                                        theme,
                                        colorScheme,
                                      );
                                    } else if (_isLoading) {
                                      return _buildLoadingCard(
                                        isTablet,
                                        colorScheme,
                                      );
                                    }
                                    return null;
                                  },
                                  childCount:
                                      _filteredPosts.length +
                                      (_isLoading ? 3 : 0),
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: SizedBox(height: isTablet ? 32 : 24),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreatePost,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Đăng bài'),
      ),
    );
  }

  Widget _buildEnhancedSearchSection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bài đăng...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            tooltip: 'Xóa tìm kiếm',
                          ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type Filter
                ...PostType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedType == type,
                      onSelected: (_) => _handleTypeFilter(type),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(type.icon, size: isTablet ? 18 : 16),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(type.label),
                        ],
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(width: isTablet ? 16 : 12),

                // Sort Filter
                ...SortOrder.values.map(
                  (sort) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedSort == sort,
                      onSelected: (_) => _handleSortFilter(sort),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sort.icon, size: isTablet ? 18 : 16),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(sort.label),
                        ],
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.secondaryContainer,
                      checkmarkColor: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Count and Current Scope
          if (_filteredPosts.isNotEmpty) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Text(
                  'Tìm thấy ${_filteredPosts.length} bài đăng',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: theme.hintColor,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _handleSearch('');
              _handleTypeFilter(PostType.all);
              _handleSortFilter(SortOrder.newest);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Đặt lại bộ lọc'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    Map<String, dynamic> post,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final postType = PostType.values.firstWhere(
      (type) => type.name == post['type'],
      orElse: () => PostType.all,
    );

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: () => _handlePostTap(post),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(postType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            postType.icon,
                            size: isTablet ? 16 : 14,
                            color: _getTypeColor(postType),
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            postType.label,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(postType),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(post['createdAt']),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Title
                Text(
                  post['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 18 : 16,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isTablet ? 12 : 8),

                // Content
                Text(
                  post['content'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: isTablet ? 15 : 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Images
                if (_hasImages(post)) ...[
                  SizedBox(height: isTablet ? 16 : 12),
                  SizedBox(
                    height: isTablet ? 120 : 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (post['images'] as List).length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                          width: isTablet ? 120 : 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: colorScheme.surfaceVariant,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post['images'][index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image,
                                    color: theme.hintColor,
                                    size: isTablet ? 32 : 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                SizedBox(height: isTablet ? 16 : 12),

                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: isTablet ? 16 : 14,
                      color: theme.hintColor,
                    ),
                    SizedBox(width: isTablet ? 4 : 2),
                    Text(
                      post['location'],
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Icon(
                      Icons.person_outline,
                      size: isTablet ? 16 : 14,
                      color: theme.hintColor,
                    ),
                    SizedBox(width: isTablet ? 4 : 2),
                    Expanded(
                      child: Text(
                        post['author'],
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          color: theme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Status indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 6,
                        vertical: isTablet ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(post['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusText(post['status']),
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(post['status']),
                        ),
                      ),
                    ),
                  ],
                ),

                // Reward info for lost/found items
                if (post['rewardOffered'] != null) ...[
                  SizedBox(height: isTablet ? 8 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: isTablet ? 14 : 12,
                          color: Colors.orange,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          'Hậu tạ: ${post['rewardOffered']}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isTablet, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header loading
              Row(
                children: [
                  Container(
                    height: isTablet ? 24 : 20,
                    width: isTablet ? 80 : 60,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: isTablet ? 16 : 14,
                    width: isTablet ? 60 : 50,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Title loading
              Container(
                height: isTablet ? 20 : 18,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              SizedBox(height: isTablet ? 8 : 6),

              Container(
                height: isTablet ? 20 : 18,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              SizedBox(height: isTablet ? 12 : 8),

              // Content loading
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
                  child: Container(
                    height: isTablet ? 16 : 14,
                    width:
                        MediaQuery.of(context).size.width * (0.9 - index * 0.1),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Footer loading
              Row(
                children: [
                  Container(
                    height: isTablet ? 14 : 12,
                    width: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Container(
                    height: isTablet ? 14 : 12,
                    width: isTablet ? 80 : 60,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: isTablet ? 16 : 14,
                    width: isTablet ? 50 : 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
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

  Color _getTypeColor(PostType type) {
    switch (type) {
      case PostType.findLost:
        return Colors.red;
      case PostType.foundItem:
        return Colors.green;
      case PostType.giveAway:
        return Colors.blue;
      case PostType.freePost:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'reserved':
        return Colors.blue;
      case 'available':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang hoạt động';
      case 'pending':
        return 'Chờ xử lý';
      case 'urgent':
        return 'Khẩn cấp';
      case 'reserved':
        return 'Đã đặt';
      case 'available':
        return 'Có sẵn';
      default:
        return 'Không xác định';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
