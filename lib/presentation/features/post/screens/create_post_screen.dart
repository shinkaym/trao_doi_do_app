import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/create_post_form.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class CreatePostScreen extends HookConsumerWidget {
  final Map<String, dynamic>? extra;

  const CreatePostScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    final preselectedType = extra?['type'] as PostType?;

    // Watch auth state chỉ để lấy thông tin user
    final authState = ref.watch(authProvider);

    // Track if we've already attempted refresh
    final hasRefreshed = useRef(false);

    useEffect(() {
      // Refresh user info một lần khi màn hình được tạo
      if (authState.user != null && !hasRefreshed.value) {
        hasRefreshed.value = true;

        // Delay một chút để tránh gọi trong build cycle
        Future.microtask(() {
          ref.read(authProvider.notifier).refreshUserInfo();
        });
      }

      return null;
    }, [authState.user?.id]);

    return SmartScaffold(
      title: 'Đăng bài',
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: CreatePostForm(
        isTablet: isTablet,
        theme: theme,
        colorScheme: colorScheme,
        preselectedType: preselectedType,
      ),
    );
  }
}
