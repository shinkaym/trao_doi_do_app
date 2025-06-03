import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentImageIndex = 0;
  bool _isLoading = false;
  bool _isRegistered = false;
  bool _showFullDescription = false;

  // Mock data - trong thực tế sẽ fetch từ API
  Map<String, dynamic>? _item;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadItemData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadItemData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data based on itemId
    _item = {
      'id': widget.itemId,
      'title': 'Áo sơ mi trắng size M',
      'description':
          'Áo sơ mi trắng chất liệu cotton cao cấp, được giặt sạch và bảo quản cẩn thận. Áo còn rất mới, chỉ mặc vài lần. Phù hợp cho công sở hoặc các sự kiện trang trọng. Màu trắng tinh khôi, dễ phối đồ.',
      'type': 'old', // or 'lost'
      'category': 'Quần áo',
      'condition': 'Tốt',
      'size': 'M',
      'brand': 'Uniqlo',
      'color': 'Trắng',
      'material': 'Cotton',
      'location': 'Quận 1, TP.HCM',
      'detailLocation': '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1',
      'images': [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800',
        'https://images.unsplash.com/photo-1621072156002-e2fccdc0b176?w=800',
        'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
        'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=800',
      ],
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'available',
      'donor': {
        'name': 'Nguyễn Văn A',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        'phone': '0901234567',
        'email': 'nguyenvana@email.com',
        'rating': 4.8,
        'totalDonations': 15,
        'joinDate': DateTime.now().subtract(const Duration(days: 365)),
      },
      'registeredUsers': 3,
      'maxRegistrations': 5,
      'registrationDeadline': DateTime.now().add(const Duration(days: 3)),
      'pickupOptions': [
        {
          'type': 'self_pickup',
          'label': 'Tự đến lấy',
          'description': 'Đến địa chỉ người tặng để nhận đồ',
          'available': true,
        },
        {
          'type': 'delivery',
          'label': 'Giao hàng',
          'description': 'Người tặng sẽ giao đến địa chỉ của bạn',
          'available': false,
        },
        {
          'type': 'meeting_point',
          'label': 'Hẹn gặp',
          'description': 'Gặp nhau tại địa điểm thuận tiện',
          'available': true,
        },
      ],
      'rules': [
        'Vui lòng đến đúng giờ hẹn',
        'Mang theo giấy tờ tùy thân để xác minh',
        'Không được bán lại món đồ này',
        'Liên hệ trước khi đến 30 phút',
      ],
    };

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _handleRegister() async {
    if (_item == null) return;

    final shouldRegister = await _showRegisterDialog();
    if (!shouldRegister) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isRegistered = true;
      });

      _showSuccessDialog();
    }
  }

  Future<bool> _showRegisterDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận đăng ký'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn có chắc chắn muốn đăng ký nhận món đồ này?'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lưu ý quan trọng:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._item!['rules']
                          .map<Widget>(
                            (rule) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      rule,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đăng ký thành công!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chúng tôi đã ghi nhận đăng ký của bạn. Người tặng sẽ liên hệ với bạn sớm nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pop(); // Return to previous screen
                  },
                  child: const Text('Đồng ý'),
                ),
              ),
            ],
          ),
    );
  }

  void _handleContact() {
    final donor = _item!['donor'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(donor['avatar']),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donor['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${donor['rating']}'),
                              const SizedBox(width: 12),
                              Text('${donor['totalDonations']} món đã tặng'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Handle call
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Gọi điện'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Handle message
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Nhắn tin'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _handleShare() {
    // Handle share functionality
    context.showInfoSnackBar('Đã sao chép link chia sẻ');
  }

  void _handleFavorite() {
    // Handle favorite functionality
    context.showInfoSnackBar('Đã thêm vào danh sách yêu thích');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    if (_isLoading && _item == null) {
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

    if (_item == null) {
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
        body: const Center(child: Text('Không tìm thấy thông tin món đồ')),
      );
    }

    final isLostItem = _item!['type'] == 'lost';
    final images = List<String>.from(_item!['images']);
    final donor = _item!['donor'];

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Image Gallery AppBar
            SliverAppBar(
              expandedHeight: isTablet ? 400 : 300,
              pinned: true,
              backgroundColor: colorScheme.primary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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
                    onPressed: _handleFavorite,
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Image Gallery
                    PageView.builder(
                      controller: _pageController,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                                  margin: const EdgeInsets.only(right: 6),
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
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Header
                  _buildItemHeader(isTablet, theme, colorScheme, isLostItem),

                  // Item Details
                  _buildItemDetails(isTablet, theme, colorScheme),

                  // Description
                  _buildDescription(isTablet, theme, colorScheme),

                  // Donor Info
                  _buildDonorInfo(isTablet, theme, colorScheme, donor),

                  // Pickup Options
                  _buildPickupOptions(isTablet, theme, colorScheme),

                  // Registration Info
                  _buildRegistrationInfo(isTablet, theme, colorScheme),

                  // Rules
                  _buildRules(isTablet, theme, colorScheme),

                  // Bottom padding for floating button
                  SizedBox(height: isTablet ? 120 : 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar
      bottomNavigationBar: _buildBottomActionBar(
        isTablet,
        theme,
        colorScheme,
        isLostItem,
      ),
    );
  }

  Widget _buildItemHeader(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLostItem,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Badge and Status
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 5,
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
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Có sẵn',
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Title
          Text(
            _item!['title'],
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Location and Time
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Expanded(
                child: Text(
                  _item!['location'],
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Icon(
                Icons.schedule,
                size: isTablet ? 16 : 14,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 4 : 3),
              Text(
                _formatTime(_item!['createdAt']),
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final details = [
      {
        'icon': Icons.category_outlined,
        'label': 'Danh mục',
        'value': _item!['category'],
      },
      {
        'icon': Icons.star_outline,
        'label': 'Tình trạng',
        'value': _item!['condition'],
      },
      if (_item!['size'] != null)
        {'icon': Icons.straighten, 'label': 'Kích cỡ', 'value': _item!['size']},
      if (_item!['brand'] != null)
        {
          'icon': Icons.local_offer_outlined,
          'label': 'Thương hiệu',
          'value': _item!['brand'],
        },
      if (_item!['color'] != null)
        {
          'icon': Icons.palette_outlined,
          'label': 'Màu sắc',
          'value': _item!['color'],
        },
      if (_item!['material'] != null)
        {
          'icon': Icons.texture,
          'label': 'Chất liệu',
          'value': _item!['material'],
        },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chi tiết',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...details
              .map(
                (detail) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  child: Row(
                    children: [
                      Icon(
                        detail['icon'] as IconData,
                        size: isTablet ? 20 : 18,
                        color: theme.hintColor,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Text(
                        '${detail['label']}:',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Expanded(
                        child: Text(
                          detail['value'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDescription(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final description = _item!['description'];
    final isLongDescription = description.length > 150;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            isLongDescription && !_showFullDescription
                ? '${description.substring(0, 150)}...'
                : description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          if (isLongDescription) ...[
            SizedBox(height: isTablet ? 8 : 6),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(
                _showFullDescription ? 'Thu gọn' : 'Xem thêm',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDonorInfo(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> donor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Người tặng',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 25,
                backgroundImage: NetworkImage(donor['avatar']),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor['name'],
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: isTablet ? 16 : 14,
                          color: Colors.amber,
                        ),
                        SizedBox(width: isTablet ? 4 : 3),
                        Text(
                          '${donor['rating']}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Text(
                          '${donor['totalDonations']} món đã tặng',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 4 : 3),
                    Text(
                      'Tham gia ${_formatJoinDate(donor['joinDate'])}',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              OutlinedButton(
                onPressed: _handleContact,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                ),
                child: Text(
                  'Liên hệ',
                  style: TextStyle(fontSize: isTablet ? 12 : 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupOptions(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final pickupOptions = List<Map<String, dynamic>>.from(
      _item!['pickupOptions'],
    );

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cách thức nhận đồ',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...pickupOptions
              .map(
                (option) => Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color:
                        option['available']
                            ? colorScheme.primary.withOpacity(0.05)
                            : colorScheme.outline.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          option['available']
                              ? colorScheme.primary.withOpacity(0.2)
                              : colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option['available'] ? Icons.check_circle : Icons.cancel,
                        size: isTablet ? 20 : 18,
                        color:
                            option['available']
                                ? colorScheme.primary
                                : theme.hintColor,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['label'],
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    option['available']
                                        ? colorScheme.onSurface
                                        : theme.hintColor,
                              ),
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              option['description'],
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRegistrationInfo(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final registeredUsers = _item!['registeredUsers'];
    final maxRegistrations = _item!['maxRegistrations'];
    final deadline = _item!['registrationDeadline'];
    final progress = registeredUsers / maxRegistrations;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin đăng ký',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Registration Progress
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Đã đăng ký: $registeredUsers/$maxRegistrations người',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),

          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 0.8 ? Colors.orange : colorScheme.primary,
            ),
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Deadline
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Hạn đăng ký: ${_formatDeadline(deadline)}',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          if (registeredUsers >= maxRegistrations) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: isTablet ? 16 : 14,
                    color: Colors.orange.shade700,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Expanded(
                    child: Text(
                      'Đã đủ số lượng đăng ký',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: Colors.orange.shade700,
                      ),
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

  Widget _buildRules(bool isTablet, ThemeData theme, ColorScheme colorScheme) {
    final rules = List<String>.from(_item!['rules']);

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_outlined,
                size: isTablet ? 20 : 18,
                color: colorScheme.primary,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Quy định khi nhận đồ',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          ...rules
              .map(
                (rule) => Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isTablet ? 6 : 5,
                        height: isTablet ? 6 : 5,
                        margin: EdgeInsets.only(
                          top: isTablet ? 6 : 5,
                          right: isTablet ? 12 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rule,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLostItem,
  ) {
    final registeredUsers = _item!['registeredUsers'];
    final maxRegistrations = _item!['maxRegistrations'];
    final isFull = registeredUsers >= maxRegistrations;
    final deadline = _item!['registrationDeadline'];
    final isExpired = DateTime.now().isAfter(deadline);

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
            // Contact Button
            OutlinedButton.icon(
              onPressed: _handleContact,
              icon: Icon(Icons.message_outlined, size: isTablet ? 18 : 16),
              label: Text(
                'Liên hệ',
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

            // Register Button
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (_isRegistered || isFull || isExpired || _isLoading)
                        ? null
                        : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  backgroundColor:
                      _isRegistered
                          ? Colors.green
                          : (isFull || isExpired)
                          ? theme.disabledColor
                          : colorScheme.primary,
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: isTablet ? 20 : 16,
                          height: isTablet ? 20 : 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isRegistered
                                  ? Icons.check_circle
                                  : isFull
                                  ? Icons.close
                                  : isExpired
                                  ? Icons.schedule
                                  : Icons.how_to_reg,
                              size: isTablet ? 18 : 16,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Text(
                              _isRegistered
                                  ? 'Đã đăng ký'
                                  : isFull
                                  ? 'Đã đủ người'
                                  : isExpired
                                  ? 'Hết hạn'
                                  : 'Đăng ký nhận',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w600,
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

  String _formatTime(DateTime dateTime) {
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

  String _formatJoinDate(DateTime joinDate) {
    final now = DateTime.now();
    final difference = now.difference(joinDate);

    if (difference.inDays < 30) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Đã hết hạn';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ nữa';
    } else {
      return '${difference.inDays} ngày nữa';
    }
  }
}
