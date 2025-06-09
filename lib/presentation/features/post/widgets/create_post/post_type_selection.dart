import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';

class PostTypeSelection extends StatelessWidget {
  final CreatePostType selectedType;
  final Function(CreatePostType) onTypeChanged;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const PostTypeSelection({
    required this.selectedType,
    required this.onTypeChanged,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại bài đăng',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            childAspectRatio: isTablet ? 2 : 1.8,
            crossAxisSpacing: isTablet ? 16 : 12,
            mainAxisSpacing: isTablet ? 16 : 12,
          ),
          itemCount: CreatePostType.values.length,
          itemBuilder: (context, index) {
            final type = CreatePostType.values[index];
            final isSelected = selectedType == type;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected
                          ? type.color
                          : colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => onTypeChanged(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type.icon,
                        size: isTablet ? 32 : 28,
                        color: isSelected ? type.color : theme.hintColor,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? type.color : theme.hintColor,
                          fontSize: isTablet ? 14 : 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}