import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final currentPage = useState(0);
    final pageController = usePageController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    )..forward();
    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    final pages = useMemoized(
      () => [
        OnboardingData(
          title: 'Đồ cũ, giá trị mới',
          subtitle: 'Kết nối & Trao đổi đồ cũ',
          description:
              'Dễ dàng tặng, nhận hoặc trao đổi đồ dùng cũ với cộng đồng quanh bạn.',
          icon: Icons.recycling,
          color: Colors.green,
        ),
        OnboardingData(
          title: 'Mất đồ? Đừng lo!',
          subtitle: 'Tìm lại đồ thất lạc',
          description:
              'Đăng thông tin hoặc tìm kiếm trong kho đồ thất lạc – có thể ai đó đã nhặt được món đồ của bạn.',
          icon: Icons.search,
          color: Colors.blue,
        ),
        OnboardingData(
          title: 'Đăng bài trong vài giây',
          subtitle: 'Đăng bài & Quản lý dễ dàng',
          description:
              'Chia sẻ món đồ bạn muốn tặng hoặc tìm kiếm – quản lý mọi thứ ngay trên ứng dụng.',
          icon: Icons.add_circle_outline,
          color: Colors.orange,
        ),
        OnboardingData(
          title: 'Cộng đồng giúp đỡ lẫn nhau',
          subtitle: 'Hỗ trợ từ cộng đồng',
          description:
              'Mỗi hành động nhỏ đều mang lại giá trị – hãy là một phần của cộng đồng chia sẻ.',
          icon: Icons.people,
          color: Colors.purple,
        ),
        OnboardingData(
          title: 'Sẵn sàng chưa?',
          subtitle: 'Bắt đầu sử dụng',
          description:
              'Tạo tài khoản và bắt đầu hành trình chia sẻ hoặc tìm lại món đồ yêu thích của bạn.',
          icon: Icons.rocket_launch,
          color: Colors.teal,
        ),
      ],
    );

    final isLastPage = currentPage.value == pages.length - 1;

    void nextPage() {
      if (currentPage.value < pages.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        context.goNamed('posts');
      }
    }

    void previousPage() {
      if (currentPage.value > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isTablet, isLastPage, () {
                context.goNamed('posts');
              }),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => currentPage.value = index,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: _buildPageContent(context, pages[index], isTablet),
                    );
                  },
                ),
              ),
              _buildBottomSection(
                context: context,
                isTablet: isTablet,
                currentPage: currentPage.value,
                pages: pages,
                isLastPage: isLastPage,
                onNext: nextPage,
                onPrevious: previousPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isTablet,
    bool isLastPage,
    VoidCallback onSkip,
  ) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 50 : 40,
                height: isTablet ? 50 : 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.apps,
                            color: Colors.white,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'SAS',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!isLastPage)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Bỏ qua',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    OnboardingData data,
    bool isTablet,
  ) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48 : 24,
        vertical: isTablet ? 32 : 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 200 : 150,
            height: isTablet ? 200 : 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  data.color.withOpacity(0.1),
                  data.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: data.color.withOpacity(0.2), width: 2),
            ),
            child: Icon(data.icon, size: isTablet ? 80 : 60, color: data.color),
          ),
          SizedBox(height: isTablet ? 48 : 32),
          Text(
            data.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 32 : 28,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            data.subtitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w600,
              color: data.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
              height: 1.6,
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection({
    required BuildContext context,
    required bool isTablet,
    required int currentPage,
    required List<OnboardingData> pages,
    required bool isLastPage,
    required VoidCallback onNext,
    required VoidCallback onPrevious,
  }) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                width:
                    currentPage == index
                        ? (isTablet ? 40 : 32)
                        : (isTablet ? 12 : 8),
                height: isTablet ? 12 : 8,
                decoration: BoxDecoration(
                  color:
                      currentPage == index
                          ? pages[currentPage].color
                          : theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          Row(
            children: [
              if (currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.hintColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 14,
                      ),
                    ),
                    child: Text(
                      'Quay lại',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                flex: 2,
                child:
                    isLastPage
                        ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.goNamed('register'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: pages[currentPage].color,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16 : 14,
                                  ),
                                ),
                                child: Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: pages[currentPage].color,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.goNamed('login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pages[currentPage].color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16 : 14,
                                  ),
                                  elevation: 4,
                                  shadowColor: pages[currentPage].color
                                      .withOpacity(0.3),
                                ),
                                child: Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pages[currentPage].color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            elevation: 4,
                            shadowColor: pages[currentPage].color.withOpacity(
                              0.3,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tiếp theo',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Icon(
                                Icons.arrow_forward,
                                size: isTablet ? 20 : 18,
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
