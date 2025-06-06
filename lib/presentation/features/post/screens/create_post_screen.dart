import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/create_post_form.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/login_prompt.dart';
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

    return SmartScaffold(
      title: 'Đăng bài',
      appBarType: AppBarType.standard,
      showBackButton: true,
      body:
          authState.isLoggedIn
              ? CreatePostForm(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
              )
              : LoginPrompt(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
              ),
    );
  }
}
