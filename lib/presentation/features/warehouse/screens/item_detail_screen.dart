import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/bottom_action_bar.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/contact_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/dialogs.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/donor_info.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/image_gallery.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/item_description.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/item_details.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/item_header.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/item_rules.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/pickup_options.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/widgets/item_detail/registration_info.dart';

class ItemDetailScreen extends HookConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

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
    final isLoading = useState(false);
    final isRegistered = useState(false);
    final showFullDescription = useState(false);
    final item = useState<Map<String, dynamic>?>(null);

    // Load item data function
    Future<void> loadItemData() async {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data based on itemId
      item.value = {
        'id': itemId,
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

      isLoading.value = false;
      animationController.forward();
    }

    // Load data on first build
    useEffect(() {
      loadItemData();
      return null;
    }, []);

    // Event handlers
    Future<void> handleRegister() async {
      if (item.value == null) return;

      final shouldRegister = await showRegisterDialog(context, item.value!);
      if (!shouldRegister) return;

      // Show loading dialog
      context.showLoadingDialog(message: 'Đang đăng ký...');

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Dismiss loading dialog
        context.dismissDialog();

        isRegistered.value = true;

        // Show success dialog
        context.showSuccessDialog(
          title: 'Đăng ký thành công!',
          message:
              'Chúng tôi đã ghi nhận đăng ký của bạn. Người tặng sẽ liên hệ với bạn sớm nhất.',
          buttonText: 'Đồng ý',
        );
      } catch (e) {
        // Dismiss loading dialog
        context.dismissDialog();

        // Show error dialog
        context.showErrorDialog(
          message: 'Có lỗi xảy ra khi đăng ký. Vui lòng thử lại.',
        );
      }
    }

    void handleContact() {
      final donor = item.value!['donor'];
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => ContactBottomSheet(donor: donor),
      );
    }

    void handleShare() {
      context.showInfoSnackBar('Đã sao chép link chia sẻ');
    }

    void handleFavorite() {
      context.showInfoSnackBar('Đã thêm vào danh sách yêu thích');
    }

    // UI
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    if (isLoading.value && item.value == null) {
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

    if (item.value == null) {
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

    final isLostItem = item.value!['type'] == 'lost';
    final images = List<String>.from(item.value!['images']);
    final donor = item.value!['donor'];

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: fadeAnimation,
        child: CustomScrollView(
          slivers: [
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
                    onPressed: handleShare,
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
                    onPressed: handleFavorite,
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: ImageGallery(
                  images: images,
                  pageController: pageController,
                  currentImageIndex: currentImageIndex,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemHeader(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    isLostItem: isLostItem,
                    formatTime: TimeUtils.formatTimeAgo,
                  ),
                  ItemDetails(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  ItemDescription(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    showFullDescription: showFullDescription,
                  ),
                  DonorInfo(
                    donor: donor,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    formatJoinDate: TimeUtils.formatTimeAgo,
                    onContact: handleContact,
                  ),
                  PickupOptions(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  RegistrationInfo(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    formatDeadline: TimeUtils.formatTimeAgo,
                  ),
                  ItemRules(
                    item: item.value!,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: isTablet ? 120 : 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        item: item.value!,
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
        isLostItem: isLostItem,
        isRegistered: isRegistered.value,
        isLoading: isLoading.value,
        onContact: handleContact,
        onRegister: handleRegister,
      ),
    );
  }
}
