import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_provider.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
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

    // State để track logout loading riêng biệt
    final isLoggingOut = useState(false);

    final avatarWidget = useMemoized(
      () => _buildAvatarWidget(
        authState: authState,
        isTablet: isTablet,
        colorScheme: colorScheme,
      ),
      [authState.user?.avatar, isTablet],
    );

    // Listen for auth state changes để show snackbar
    useEffect(() {
      if (authState.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).clearSuccess();
        });
      }

      if (authState.failure != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showErrorSnackBar(authState.failure!.message);
          ref.read(authProvider.notifier).clearError();
        });
      }

      return null;
    }, [authState.successMessage, authState.failure]);

    // Listen for logout completion
    useEffect(() {
      if (isLoggingOut.value && !authState.isLoading) {
        isLoggingOut.value = false;
      }
      return null;
    }, [authState.isLoading]);

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
                  child: _buildLoggedInContent(
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    currentThemeMode: currentThemeMode,
                    authState: authState,
                    context: context,
                    ref: ref,
                    isLoggingOut: isLoggingOut.value,
                    onLogoutStateChanged: (bool loading) {
                      isLoggingOut.value = loading;
                    },
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

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
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

    // Kiểm tra nếu có avatar
    if (authState.user?.avatar != null && authState.user!.avatar.isNotEmpty) {
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

    // Default avatar khi chưa có ảnh
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: colorScheme.primary,
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
            // Avatar
            avatarWidget,
            SizedBox(height: isTablet ? 20 : 16),

            // User info
            Text(
              authState.user?.fullName ?? 'Người dùng',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authState.user?.email ?? 'email@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: isTablet ? 16 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (authState.user?.phoneNumber != null &&
                authState.user!.phoneNumber.isNotEmpty) ...[
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
    required bool isLoggingOut,
    required Function(bool) onLogoutStateChanged,
  }) {
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
          onTap: () => context.pushNamed(RouteNames.editProfile),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          onTap: () => context.pushNamed(RouteNames.changePassword),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.leaderboard_outlined,
          title: 'Bảng xếp hạng',
          onTap: () => context.pushNamed(RouteNames.ranking),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.history,
          title: 'Lịch sử bài đăng',
          onTap: () => context.pushNamed(RouteNames.myPosts),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _buildMenuItem(
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
          icon: Icons.calendar_today_outlined,
          title: 'Danh sách cuộc hẹn',
          onTap: () => context.pushNamed(RouteNames.appointments),
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
                isLoggingOut
                    ? null
                    : () => _handleLogout(context, ref, onLogoutStateChanged),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon:
                isLoggingOut
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
              isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất',
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

  Widget _buildMenuItem({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
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
              HapticFeedback.lightImpact();
            },
            activeTrackColor: colorScheme.primaryContainer,
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.surfaceVariant,
          ),
        ],
      ),
    );
  }

  void _handleLogout(
    BuildContext context,
    WidgetRef ref,
    Function(bool) onLogoutStateChanged,
  ) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Đăng xuất',
      content: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      isDangerous: true,
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      onLogoutStateChanged(true); // Bật loading cho button
      ref.read(authProvider.notifier).logout();
    }
  }
}
