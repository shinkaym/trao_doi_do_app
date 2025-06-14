import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';

class AuthLoginOverlay extends HookConsumerWidget {
  final Widget child;
  final String? requiredFeature;
  final bool showOverlay;

  const AuthLoginOverlay({
    super.key,
    required this.child,
    this.requiredFeature,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Animation controllers using hooks
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    final backgroundController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // Animations using useMemoized to avoid recreation
    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOutQuart,
        ),
      ),
      [animationController],
    );

    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      ),
      [animationController],
    );

    final backgroundAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: backgroundController, curve: Curves.easeOut),
      ),
      [backgroundController],
    );

    // Helper functions using useCallback to avoid recreation
    final showOverlayFunc = useCallback(() {
      backgroundController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        animationController.forward();
      });
    }, [animationController, backgroundController]);

    final hideOverlayFunc = useCallback(() async {
      await animationController.reverse();
      await backgroundController.reverse();
    }, [animationController, backgroundController]);

    // Trigger animation when overlay should be shown
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!authState.isLoggedIn && showOverlay) {
          showOverlayFunc();
        }
      });
      return null;
    }, [authState.isLoggedIn, showOverlay, showOverlayFunc]);

    return Stack(
      children: [
        // Main content
        child,

        // Overlay
        if (!authState.isLoggedIn && showOverlay)
          AnimatedBuilder(
            animation: backgroundAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(
                  0.7 * backgroundAnimation.value,
                ),
                child: child,
              );
            },
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: _buildOverlayContent(
                      context: context,
                      isTablet: isTablet,
                      theme: theme,
                      colorScheme: colorScheme,
                      authState: authState,
                      hideOverlay: hideOverlayFunc,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayContent({
    required BuildContext context,
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required AuthState authState,
    required VoidCallback hideOverlay,
  }) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(isTablet ? 48 : 24),
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                _buildHeader(
                  context: context,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  hideOverlay: hideOverlay,
                ),

                // Content
                _buildContent(
                  context: context,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  authState: authState,
                  hideOverlay: hideOverlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required VoidCallback hideOverlay,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: hideOverlay,
              icon: const Icon(Icons.close),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 16 : 8),

          // Icon
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.lock_outline,
              size: isTablet ? 48 : 40,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Title
          Text(
            'Cần đăng nhập',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 28 : 24,
            ),
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Subtitle
          Text(
            requiredFeature != null
                ? 'Bạn cần đăng nhập để sử dụng $requiredFeature'
                : 'Đăng nhập để truy cập đầy đủ tính năng',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required AuthState authState,
    required VoidCallback hideOverlay,
  }) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          // Benefits section
          _buildBenefitsSection(
            isTablet: isTablet,
            theme: theme,
            colorScheme: colorScheme,
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Action buttons
          _buildActionButtons(
            context: context,
            isTablet: isTablet,
            colorScheme: colorScheme,
            authState: authState,
            hideOverlay: hideOverlay,
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Skip button (optional)
          _buildSkipButton(
            context: context,
            isTablet: isTablet,
            theme: theme,
            hideOverlay: hideOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection({
    required bool isTablet,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final benefits = [
      {
        'icon': Icons.favorite_outline,
        'title': 'Quản lý yêu thích',
        'description': 'Lưu các bài đăng quan tâm',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Trao đổi trực tiếp',
        'description': 'Nhắn tin với người dùng khác',
      },
      {
        'icon': Icons.add_circle_outline,
        'title': 'Đăng bài miễn phí',
        'description': 'Chia sẻ đồ dùng của bạn',
      },
    ];

    return Column(
      children:
          benefits.map((benefit) {
            return Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      benefit['icon'] as IconData,
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
                          benefit['title'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          benefit['description'] as String,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required bool isTablet,
    required ColorScheme colorScheme,
    required AuthState authState,
    required VoidCallback hideOverlay,
  }) {
    return Column(
      children: [
        // Login button
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 50,
          child: ElevatedButton.icon(
            onPressed:
                authState.isLoading
                    ? null
                    : () async {
                      hideOverlay();
                      if (context.mounted) {
                        context.goNamed('login');
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            icon:
                authState.isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                    : const Icon(Icons.login_rounded),
            label: Text(
              authState.isLoading ? 'Đang xử lý...' : 'Đăng nhập',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Register button
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 50,
          child: OutlinedButton.icon(
            onPressed:
                authState.isLoading
                    ? null
                    : () async {
                      hideOverlay();
                      if (context.mounted) {
                        context.goNamed('register');
                      }
                    },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.person_add_rounded),
            label: Text(
              'Tạo tài khoản mới',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton({
    required BuildContext context,
    required bool isTablet,
    required ThemeData theme,
    required VoidCallback hideOverlay,
  }) {
    return TextButton(
      onPressed: hideOverlay,
      child: Text(
        'Bỏ qua',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: theme.hintColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Wrapper widget để sử dụng overlay dễ dàng hơn
class AuthRequiredOverlayWrapper extends HookConsumerWidget {
  final Widget child;
  final String? requiredFeature;
  final bool forceShow;

  const AuthRequiredOverlayWrapper({
    super.key,
    required this.child,
    this.requiredFeature,
    this.forceShow = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return AuthLoginOverlay(
      requiredFeature: requiredFeature,
      showOverlay: forceShow || !authState.isLoggedIn,
      child: child,
    );
  }
}

// Extension methods để sử dụng thuận tiện hơn
extension AuthOverlayExtension on Widget {
  Widget requireAuth({String? feature}) {
    return AuthRequiredOverlayWrapper(requiredFeature: feature, child: this);
  }

  Widget showAuthOverlay({String? feature, bool force = false}) {
    return AuthRequiredOverlayWrapper(
      requiredFeature: feature,
      forceShow: force,
      child: this,
    );
  }
}
