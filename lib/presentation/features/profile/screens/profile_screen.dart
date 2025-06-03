import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Giả lập trạng thái đăng nhập
  bool _isLoggedIn =
      true; // Thay đổi thành false để test trạng thái chưa đăng nhập

  // User data (giả lập)
  final Map<String, String> _userData = {
    'name': 'Nguyễn Văn An',
    'email': 'nguyenvanan@email.com',
    'phone': '+84 901 234 567',
    'avatar': '', // URL ảnh đại diện
  };

  void _handleLogin() {
    context.pushNamed('login');
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isLoggedIn = false;
                  });
                  context.showSuccessSnackBar('Đã đăng xuất thành công');
                },
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );
  }

  void _handleEditProfile() {
    context.pushNamed('edit-profile');
  }

  void _handleChangePassword() {
    context.pushNamed('change-password');
  }

  void _handlePostHistory() {
    context.pushNamed('post-history');
  }

  void _handleNotifications() {
    context.pushNamed('notifications');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Watch the current theme mode from Riverpod
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Hồ sơ',
        notificationCount: 3, // Số thông báo (có thể lấy từ provider/state)
        onNotificationTap: _handleNotifications,
        showBackButton: false, // Không hiển thị nút back vì đây là trang chính
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(isTablet, theme, colorScheme),

              // Content Section
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child:
                      _isLoggedIn
                          ? _buildLoggedInContent(
                            isTablet,
                            theme,
                            colorScheme,
                            currentThemeMode,
                          )
                          : _buildLoggedOutContent(
                            isTablet,
                            theme,
                            colorScheme,
                            currentThemeMode,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 40 : 30,
          horizontal: 24,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child:
                  _isLoggedIn && _userData['avatar']!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: Image.network(
                          _userData['avatar']!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: isTablet ? 50 : 40,
                                color: Colors.white,
                              ),
                        ),
                      )
                      : Icon(
                        _isLoggedIn ? Icons.person : Icons.person_outline,
                        size: isTablet ? 50 : 40,
                        color: Colors.white,
                      ),
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Name, Email and Phone
            if (_isLoggedIn) ...[
              Text(
                _userData['name']!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Text(
                _userData['email']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Text(
                _userData['phone']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ] else ...[
              Text(
                'Hồ sơ cá nhân',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInContent(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    ThemeMode currentThemeMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 24 : 16),

        // Menu Items
        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.edit_outlined,
          title: 'Chỉnh sửa thông tin',
          subtitle: 'Cập nhật thông tin cá nhân',
          onTap: _handleEditProfile,
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          subtitle: 'Thay đổi mật khẩu đăng nhập',
          onTap: _handleChangePassword,
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.history, // Gợi ý biểu tượng phù hợp hơn
          title: 'Lịch sử bài đăng',
          subtitle: 'Xem các bài đăng trước đây',
          onTap: _handlePostHistory, // Đổi tên hàm cho đúng ý nghĩa
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Theme Settings
        _buildThemeSettings(isTablet, theme, colorScheme, currentThemeMode),
        SizedBox(height: isTablet ? 32 : 24),

        // Logout Button
        SizedBox(
          height: isTablet ? 56 : 50,
          child: ElevatedButton.icon(
            onPressed: _handleLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),
      ],
    );
  }

  Widget _buildLoggedOutContent(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    ThemeMode currentThemeMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Not logged in message
        Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
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
              Icon(
                Icons.person_off_outlined,
                size: isTablet ? 64 : 48,
                color: theme.hintColor,
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                'Bạn chưa đăng nhập',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Đăng nhập để truy cập đầy đủ tính năng',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: theme.hintColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 20),
              SizedBox(
                width: double.infinity,
                height: isTablet ? 56 : 50,
                child: ElevatedButton.icon(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Theme Settings (available even when not logged in)
        _buildThemeSettings(isTablet, theme, colorScheme, currentThemeMode),
        SizedBox(height: isTablet ? 32 : 24),
      ],
    );
  }

  Widget _buildMenuItem({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: isTablet ? 24 : 20,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.hintColor,
              size: isTablet ? 24 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettings(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    ThemeMode currentThemeMode,
  ) {
    final isDarkMode = currentThemeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: isTablet ? 24 : 20,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ tối',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isDarkMode ? 'Đang bật chế độ tối' : 'Đang tắt chế độ tối',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (bool value) async {
              // Use the Riverpod provider to toggle theme
              await ref.read(themeModeProvider.notifier).toggleTheme();

              // Show feedback to user
              if (mounted) {
                context.showInfoSnackBar(
                  value
                      ? 'Đã chuyển sang chế độ tối'
                      : 'Đã chuyển sang chế độ sáng',
                );
              }
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
