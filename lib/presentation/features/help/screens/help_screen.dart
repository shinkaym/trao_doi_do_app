import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/help/data/help_data.dart';
import 'package:trao_doi_do_app/presentation/models/help_item.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class HelpScreen extends HookConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    void showHelpDialog(HelpItem item) {
      context.showHelpDialog(
        title: item.title,
        content: item.description,
        icon: item.icon,
        buttonText: 'Đã hiểu',
      );
    }

    return SmartScaffold(
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(isTablet, theme, colorScheme),

              SizedBox(height: isTablet ? 32 : 24),

              // Help Items Grid
              _buildHelpItemsGrid(isTablet, theme, colorScheme, showHelpDialog),
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
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_center,
            size: isTablet ? 64 : 56,
            color: colorScheme.primary,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Trung tâm trợ giúp',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Tìm hiểu cách sử dụng ứng dụng và các tính năng',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItemsGrid(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    Function(HelpItem) onItemTap,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: isTablet ? 16 : 0,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: isTablet ? 2.5 : 4.5,
      ),
      itemCount: HelpData.helpItems.length,
      itemBuilder: (context, index) {
        final item = HelpData.helpItems[index];
        return _buildHelpItem(item, isTablet, theme, colorScheme, onItemTap);
      },
    );
  }

  Widget _buildHelpItem(
    HelpItem item,
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    Function(HelpItem) onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: (item.iconColor ?? colorScheme.primary).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: isTablet ? 28 : 24,
                  color: item.iconColor ?? colorScheme.primary,
                ),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      _getShortDescription(item.description),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: theme.hintColor,
                        height: 1.3,
                      ),
                      maxLines: isTablet ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: isTablet ? 18 : 16,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortDescription(String fullDescription) {
    // Lấy dòng đầu tiên làm mô tả ngắn
    final lines = fullDescription.split('\n');
    return lines.first.trim();
  }
}
