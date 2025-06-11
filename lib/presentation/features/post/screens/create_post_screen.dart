import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/create_post_form.dart';
import 'package:trao_doi_do_app/presentation/widgets/login_prompt.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class CreatePostScreen extends HookConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Watch auth state
    final authState = ref.watch(authProvider);

    // Track if we've already attempted refresh
    final hasRefreshed = useRef(false);

    useEffect(() {
      // Chỉ refresh khi auth đã được khởi tạo và user đã login
      if (authState.isInitialized &&
          authState.isLoggedIn &&
          authState.user != null &&
          !hasRefreshed.value) {
        hasRefreshed.value = true;

        // Delay một chút để tránh gọi trong build cycle
        Future.microtask(() {
          ref.read(authProvider.notifier).refreshUserInfo();
        });
      }

      // Reset flag khi user logout
      if (!authState.isLoggedIn) {
        hasRefreshed.value = false;
      }

      return null;
    }, [authState.isInitialized, authState.isLoggedIn, authState.user?.id]);

    return SmartScaffold(
      title: 'Đăng bài',
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: _buildBody(authState, isTablet, theme, colorScheme),
    );
  }

  Widget _buildBody(
    AuthState authState,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Hiển thị loading khi đang khởi tạo
    if (!authState.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị form tạo bài nếu đã login
    if (authState.isLoggedIn && authState.user != null) {
      return CreatePostForm(
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
      );
    }

    // Hiển thị login prompt nếu chưa login
    return LoginPrompt(
      isTablet: isTablet,
      theme: theme,
      colorScheme: colorScheme,
    );
  }
}
