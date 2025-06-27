import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
