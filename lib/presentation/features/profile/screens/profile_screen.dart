import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Watch auth state và theme mode
    final authState = ref.watch(authProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    // Tối ưu: Chỉ show loading khi chưa initialized
    final isInitialLoading = authState.isLoading && !authState.isInitialized;

    // Tối ưu: Sử dụng useMemoized để tránh rebuild không cần thiết
    final avatarWidget = useMemoized(
      () => _buildAvatarWidget(
        authState: authState,
        isTablet: isTablet,
        colorScheme: colorScheme,
      ),
      [authState.user?.avatar, authState.isLoggedIn, isTablet],
    );

    // Listen for auth state changes để show snackbar
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.successMessage != null) {
        context.showSuccessSnackBar(next.successMessage!);
        Future.microtask(() => ref.read(authProvider.notifier).clearSuccess());
      }

      if (next.failure != null) {
        context.showErrorSnackBar(next.failure!.message);
        Future.microtask(() => ref.read(authProvider.notifier).clearError());
      }
    });

    // Tối ưu: Show loading screen khi chưa initialized
    if (isInitialLoading) {
      return SmartScaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    return SmartScaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                authState: authState,
                context: context,
                avatarWidget: avatarWidget,
              ),

              // Content Section
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child:
                      authState.isLoggedIn
                          ? _buildLoggedInContent(
                            isTablet: isTablet,
                            theme: theme,
                            colorScheme: colorScheme,
                            currentThemeMode: currentThemeMode,
                            authState: authState,
                            context: context,
                            ref: ref,
                          )
                          : _buildLoggedOutContent(
                            isTablet: isTablet,
                            theme: theme,
                            colorScheme: colorScheme,
                            currentThemeMode: currentThemeMode,
                            authState: authState,
                            context: context,
                            ref: ref,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget({
    required AuthState authState,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    final size = isTablet ? 120.0 : 100.0;
    final isLoggedIn = authState.isLoggedIn;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Giảm shadow cho trường hợp chưa đăng nhập
        boxShadow:
            isLoggedIn
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Chỉ có border nhẹ cho trường hợp chưa đăng nhập
          border:
              isLoggedIn
                  ? Border.all(color: Colors.white.withOpacity(0.4), width: 3)
                  : Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: ClipOval(child: _buildAvatar(authState, isTablet, colorScheme)),
      ),
    );
  }

  Widget _buildAvatar(
    AuthState authState,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    final size = isTablet ? 120.0 : 100.0;

    if (authState.isLoggedIn && authState.user!.avatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(
        authState.user!.avatar,
      );

      if (imageBytes != null) {
        return Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        );
      }
    }

    // Thiết kế đơn giản và nhẹ nhàng hơn cho trường hợp chưa đăng nhập
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradient nhẹ nhàng hơn
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          color: Colors.white.withOpacity(0.8),
          size: isTablet ? 48 : 40,
        ),
      ),
    );
  }

  Widget _buildHeaderSection({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required AuthState authState,
    required BuildContext context,
    required Widget avatarWidget,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 50 : 40,
          horizontal: 24,
        ),
        child: Column(
          children: [
            // Avatar - sử dụng widget đã tối ưu
            avatarWidget,
            SizedBox(height: isTablet ? 20 : 16),

            // User info hoặc title
            if (authState.isLoggedIn && authState.user != null) ...[
              Text(
                authState.user!.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 26 : 22,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  authState.user!.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: isTablet ? 16 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (authState.user!.phoneNumber.isNotEmpty) ...[
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  authState.user!.phoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 15 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ] else ...[
              Text(
                'Hồ sơ cá nhân',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 26 : 22,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                'Chưa đăng nhập',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInContent({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required ThemeMode currentThemeMode,
    required AuthState authState,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 24 : 16),

        // Tối ưu: Chỉ show loading khi có auth operation đang chạy
        if (authState.isLoading && authState.isInitialized) ...[
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],

        // Menu Items
        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.edit_outlined,
          title: 'Chỉnh sửa thông tin',
          subtitle: 'Cập nhật thông tin cá nhân',
          onTap: () => context.pushNamed('edit-profile'),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          subtitle: 'Thay đổi mật khẩu đăng nhập',
          onTap: () => context.pushNamed('change-password'),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.history,
          title: 'Lịch sử bài đăng',
          subtitle: 'Xem các bài đăng trước đây',
          onTap: () => context.pushNamed('post-history'),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // Theme Settings
        _buildThemeSettings(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          currentThemeMode: currentThemeMode,
          context: context,
          ref: ref,
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Logout Button
        SizedBox(
          height: isTablet ? 56 : 50,
          child: ElevatedButton.icon(
            onPressed:
                authState.isLoading ? null : () => _handleLogout(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon:
                authState.isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onError,
                        ),
                      ),
                    )
                    : const Icon(Icons.logout),
            label: Text(
              authState.isLoading ? 'Đang đăng xuất...' : 'Đăng xuất',
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

  Widget _buildLoggedOutContent({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required ThemeMode currentThemeMode,
    required AuthState authState,
    required BuildContext context,
    required WidgetRef ref,
  }) {
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
                  onPressed: () => context.pushNamed('login'),
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
        _buildThemeSettings(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          currentThemeMode: currentThemeMode,
          context: context,
          ref: ref,
        ),
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

  Widget _buildThemeSettings({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required ThemeMode currentThemeMode,
    required BuildContext context,
    required WidgetRef ref,
  }) {
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
              currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
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
                  currentThemeMode == ThemeMode.dark
                      ? 'Đang bật chế độ tối'
                      : 'Đang tắt chế độ tối',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool value) async {
              await ref.read(themeModeProvider.notifier).toggleTheme();
              HapticFeedback.lightImpact(); // Thêm haptic feedback
            },
            // activeColor: colorScheme.primary,
            activeTrackColor: colorScheme.primaryContainer,
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.surfaceVariant,
          ),
        ],
      ),
    );
  }

  // Tối ưu: Thêm confirmation dialog cho logout
  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Đăng xuất',
      content: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      isDangerous: true,
    );

    if (confirmed == true) {
      // Thêm haptic feedback
      HapticFeedback.mediumImpact();
      // Call logout from AuthNotifier
      ref.read(authProvider.notifier).logout();
    }
  }
}
