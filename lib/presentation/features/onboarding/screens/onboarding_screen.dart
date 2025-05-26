import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/widgets/onboarding_page.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Chào mừng bạn đến với Lost & Found',
      'description':
          'Nền tảng giúp bạn tìm kiếm và báo cáo đồ thất lạc một cách dễ dàng.',
    },
    {
      'title': 'Dễ dàng tìm kiếm và báo cáo',
      'description':
          'Tìm kiếm đồ thất lạc hoặc báo cáo khi bạn tìm thấy đồ của người khác.',
    },
    {
      'title': 'Luôn cập nhật thông tin',
      'description':
          'Nhận thông báo khi có người tìm thấy đồ của bạn hoặc có thông tin mới.',
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    // TODO: Lưu flag “đã xem onboarding” vào SharedPreferences hoặc SecureStorage
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    title: page['title']!,
                    description: page['description']!,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.all(4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? Colors.black
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                text:
                    _currentPage == _pages.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                onPressed: _onNext,
              ),
            ),
            const SizedBox(height: 10),

            TextButton(onPressed: _goToLogin, child: const Text('Bỏ qua')),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
