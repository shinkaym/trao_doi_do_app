import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

// Enum cho loại đồ
enum ItemType {
  all('Tất cả', Icons.inventory),
  lost('Đồ thất lạc', Icons.help_outline),
  old('Đồ cũ', Icons.shopping_bag);

  const ItemType(this.label, this.icon);
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

class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _hasMoreData = true;
  ItemType _selectedType = ItemType.all;
  SortOrder _selectedSort = SortOrder.newest;
  String _searchQuery = '';

  // Mock data với nhiều ảnh cho mỗi món đồ
  List<Map<String, dynamic>> _allItems = [
    {
      'id': '1',
      'title': 'Áo sơ mi trắng size M',
      'description': 'Áo sơ mi trắng, chất liệu cotton, còn mới 90%',
      'type': 'old',
      'category': 'Quần áo',
      'condition': 'Tốt',
      'location': 'Quận 1, TP.HCM',
      'images': [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
        'https://images.unsplash.com/photo-1621072156002-e2fccdc0b176?w=400',
        'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
      ],
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'available',
      'donor': 'Nguyễn Văn A',
      'contactInfo': '0901234567',
    },
    {
      'id': '2',
      'title': 'Điện thoại iPhone X',
      'description': 'Tìm thấy tại công viên Tao Đàn, có case màu xanh',
      'type': 'lost',
      'category': 'Điện tử',
      'condition': 'Tốt',
      'location': 'Quận 1, TP.HCM',
      'images': [
        'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
      ],
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'pending',
      'finder': 'Trần Thị B',
      'contactInfo': '0912345678',
    },
    {
      'id': '3',
      'title': 'Sách giáo khoa lớp 12',
      'description': 'Bộ sách giáo khoa đầy đủ các môn, còn mới',
      'type': 'old',
      'category': 'Sách vở',
      'condition': 'Khá tốt',
      'location': 'Quận 3, TP.HCM',
      'images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
        'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400',
        'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400',
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'available',
      'donor': 'Lê Văn C',
      'contactInfo': '0923456789',
    },
    {
      'id': '4',
      'title': 'Ví da màu nâu',
      'description': 'Ví da nam màu nâu, bên trong có giấy tờ',
      'type': 'lost',
      'category': 'Phụ kiện',
      'condition': 'Tốt',
      'location': 'Quận 7, TP.HCM',
      'images': [
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'claimed',
      'finder': 'Phạm Thị D',
      'contactInfo': '0934567890',
    },
    {
      'id': '5',
      'title': 'Xe đạp thể thao',
      'description': 'Xe đạp thể thao màu đỏ, 21 số, còn hoạt động tốt',
      'type': 'old',
      'category': 'Phương tiện',
      'condition': 'Khá tốt',
      'location': 'Quận 10, TP.HCM',
      'images': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?w=400',
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'reserved',
      'donor': 'Hoàng Văn E',
      'contactInfo': '0945678901',
    },
  ];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _filterItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock loading more data
    if (_allItems.length >= 20) {
      _hasMoreData = false;
    } else {
      // Add more mock items
      List<Map<String, dynamic>> newItems = [];
      for (int i = 1; i <= 5; i++) {
        newItems.add({
          'id': '${_allItems.length + i}',
          'title': 'Vật phẩm ${_allItems.length + i}',
          'description': 'Mô tả vật phẩm ${_allItems.length + i}',
          'type': (i % 2 == 0) ? 'old' : 'lost',
          'category': 'Khác',
          'condition': 'Tốt',
          'location': 'TP.HCM',
          'images': [
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400',
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
          ],
          'createdAt': DateTime.now().subtract(
            Duration(days: _allItems.length + i),
          ),
          'status': 'available',
          'donor': 'Người dùng ${_allItems.length + i}',
          'contactInfo': '090123456${i}',
        });
      }
      _allItems.addAll(newItems);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _filterItems();
    }
  }

  void _filterItems() {
    List<Map<String, dynamic>> filtered = List.from(_allItems);

    // Filter by type
    if (_selectedType != ItemType.all) {
      filtered =
          filtered.where((item) => item['type'] == _selectedType.name).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            final title = item['title'].toString().toLowerCase();
            final description = item['description'].toString().toLowerCase();
            final category = item['category'].toString().toLowerCase();
            final location = item['location'].toString().toLowerCase();
            final query = _searchQuery.toLowerCase();

            return title.contains(query) ||
                description.contains(query) ||
                category.contains(query) ||
                location.contains(query);
          }).toList();
    }

    // Sort by time
    filtered.sort((a, b) {
      final aTime = a['createdAt'] as DateTime;
      final bTime = b['createdAt'] as DateTime;

      return _selectedSort == SortOrder.newest
          ? bTime.compareTo(aTime)
          : aTime.compareTo(bTime);
    });

    setState(() {
      _filteredItems = filtered;
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterItems();
  }

  void _handleTypeFilter(ItemType type) {
    setState(() {
      _selectedType = type;
    });
    _filterItems();
  }

  void _handleSortFilter(SortOrder sort) {
    setState(() {
      _selectedSort = sort;
    });
    _filterItems();
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật danh sách'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleItemTap(Map<String, dynamic> item) {
    // Navigate to item detail
    context.pushNamed('item-detail', pathParameters: {'id': item['id']});
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Kho đồ',
        notificationCount: 3,
        onNotificationTap: _handleNotifications,
        showBackButton: false,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilterSection(isTablet, theme, colorScheme),

              // Content
              Expanded(
                child:
                    _filteredItems.isEmpty && !_isLoading
                        ? _buildEmptyState(isTablet, theme, colorScheme)
                        : CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            // Items List
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32 : 24,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < _filteredItems.length) {
                                      return _buildItemCard(
                                        _filteredItems[index],
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
                                      _filteredItems.length +
                                      (_isLoading ? 3 : 0),
                                ),
                              ),
                            ),

                            // Bottom padding
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
    );
  }

  Widget _buildSearchAndFilterSection(
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
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _handleSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đồ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
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

          SizedBox(height: isTablet ? 16 : 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type Filter
                ...ItemType.values.map(
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

          // Results Count
          if (_filteredItems.isNotEmpty) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Text(
                  'Tìm thấy ${_filteredItems.length} kết quả',
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

  Widget _buildItemCard(
    Map<String, dynamic> item,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isLostItem = item['type'] == 'lost';
    final statusColor = _getStatusColor(item['status'], colorScheme);
    final statusText = _getStatusText(item['status']);
    final images = List<String>.from(item['images']);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: InkWell(
        onTap: () => _handleItemTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLostItem
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLostItem ? Icons.help_outline : Icons.shopping_bag,
                          size: isTablet ? 16 : 14,
                          color:
                              isLostItem
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          isLostItem ? 'Đồ thất lạc' : 'Đồ cũ',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isLostItem
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Item content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images section - hiển thị nhiều ảnh
                  _buildImageSection(images, isTablet, colorScheme, theme),

                  SizedBox(width: isTablet ? 16 : 12),

                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isTablet ? 8 : 6),

                        Text(
                          item['description'],
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: theme.hintColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isTablet ? 12 : 8),

                        // Category and location
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: isTablet ? 16 : 14,
                              color: theme.hintColor,
                            ),
                            SizedBox(width: isTablet ? 6 : 4),
                            Text(
                              item['category'],
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: theme.hintColor,
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Icon(
                              Icons.location_on_outlined,
                              size: isTablet ? 16 : 14,
                              color: theme.hintColor,
                            ),
                            SizedBox(width: isTablet ? 6 : 4),
                            Flexible(
                              child: Text(
                                item['location'],
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

                        // Time and condition
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: isTablet ? 14 : 12,
                              color: theme.hintColor,
                            ),
                            SizedBox(width: isTablet ? 4 : 3),
                            Text(
                              _formatTime(item['createdAt']),
                              style: TextStyle(
                                fontSize: isTablet ? 11 : 10,
                                color: theme.hintColor,
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Icon(
                              Icons.star_outline,
                              size: isTablet ? 14 : 12,
                              color: theme.hintColor,
                            ),
                            SizedBox(width: isTablet ? 4 : 3),
                            Text(
                              item['condition'],
                              style: TextStyle(
                                fontSize: isTablet ? 11 : 10,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Widget mới để hiển thị nhiều ảnh
  Widget _buildImageSection(
    List<String> images,
    bool isTablet,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (images.isEmpty || images.every((img) => img.isEmpty)) {
      // Hiển thị placeholder khi không có ảnh
      return Container(
        width: isTablet ? 80 : 70,
        height: isTablet ? 80 : 70,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.image_outlined,
          size: isTablet ? 32 : 28,
          color: theme.hintColor,
        ),
      );
    }

    final validImages = images.where((img) => img.isNotEmpty).toList();

    if (validImages.length == 1) {
      // Hiển thị 1 ảnh
      return Container(
        width: isTablet ? 80 : 70,
        height: isTablet ? 80 : 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(
            validImages[0],
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image_outlined,
                    size: isTablet ? 32 : 28,
                    color: theme.hintColor,
                  ),
                ),
          ),
        ),
      );
    }

    // Hiển thị nhiều ảnh trong layout grid
    return SizedBox(
      width: isTablet ? 80 : 70,
      height: isTablet ? 80 : 70,
      child: _buildImageGrid(validImages, isTablet, colorScheme, theme),
    );
  }

  Widget _buildImageGrid(
    List<String> images,
    bool isTablet,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (images.length == 2) {
      // Layout 2 ảnh: chia đôi theo chiều dọc
      return Row(
        children: [
          Expanded(
            child: _buildSingleImage(
              images[0],
              isTablet,
              colorScheme,
              theme,
              BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: _buildSingleImage(
              images[1],
              isTablet,
              colorScheme,
              theme,
              BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ],
      );
    } else if (images.length == 3) {
      // Layout 3 ảnh: 1 ảnh to bên trái, 2 ảnh nhỏ bên phải
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildSingleImage(
              images[0],
              isTablet,
              colorScheme,
              theme,
              BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[1],
                    isTablet,
                    colorScheme,
                    theme,
                    BorderRadius.only(topRight: Radius.circular(12)),
                  ),
                ),
                SizedBox(height: 2),
                Expanded(
                  child: _buildSingleImage(
                    images[2],
                    isTablet,
                    colorScheme,
                    theme,
                    BorderRadius.only(bottomRight: Radius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (images.length >= 4) {
      // Layout 4+ ảnh: grid 2x2, ảnh thứ 4 có overlay số lượng còn lại
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[0],
                    isTablet,
                    colorScheme,
                    theme,
                    BorderRadius.only(topLeft: Radius.circular(12)),
                  ),
                ),
                SizedBox(width: 2),
                Expanded(
                  child: _buildSingleImage(
                    images[1],
                    isTablet,
                    colorScheme,
                    theme,
                    BorderRadius.only(topRight: Radius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[2],
                    isTablet,
                    colorScheme,
                    theme,
                    BorderRadius.only(bottomLeft: Radius.circular(12)),
                  ),
                ),
                SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    children: [
                      _buildSingleImage(
                        images[3],
                        isTablet,
                        colorScheme,
                        theme,
                        BorderRadius.only(bottomRight: Radius.circular(12)),
                      ),
                      if (images.length > 4)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${images.length - 4}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(); // Fallback
  }

  Widget _buildSingleImage(
    String imageUrl,
    bool isTablet,
    ColorScheme colorScheme,
    ThemeData theme,
    BorderRadius borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: colorScheme.surfaceVariant,
                child: Icon(
                  Icons.image_outlined,
                  size: isTablet ? 20 : 16,
                  color: theme.hintColor,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isTablet, ColorScheme colorScheme) {
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
                width: isTablet ? 80 : 60,
                height: isTablet ? 20 : 16,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Spacer(),
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 16 : 14,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: isTablet ? 16 : 14,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Container(
                      width: double.infinity * 0.8,
                      height: isTablet ? 14 : 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Container(
                      width: double.infinity * 0.6,
                      height: isTablet ? 12 : 10,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              _handleTypeFilter(ItemType.all);
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

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      case 'claimed':
        return Colors.purple;
      default:
        return colorScheme.primary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Có sẵn';
      case 'pending':
        return 'Chờ xử lý';
      case 'reserved':
        return 'Đã đặt';
      case 'claimed':
        return 'Đã nhận';
      default:
        return 'Không xác định';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
