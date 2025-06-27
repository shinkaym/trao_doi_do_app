import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class PostTypeSelection extends StatelessWidget {
  final PostType selectedType;
  final Function(PostType) onTypeChanged;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const PostTypeSelection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTypes = PostType.allPostTypesWithoutCampaign;

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
        SizedBox(height: isTablet ? 12 : 8),

        // Option 1: Horizontal Scrollable List (Recommended)
        SizedBox(
          height: isTablet ? 80 : 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredTypes.length,
            itemBuilder: (context, index) {
              final type = filteredTypes[index];
              final isSelected = selectedType == type;

              return Container(
                width: isTablet ? 120 : 100,
                margin: EdgeInsets.only(
                  right: isTablet ? 12 : 8,
                  left: index == 0 ? 0 : 0,
                ),
                child: Card(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? type.color.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type.icon,
                            size: isTablet ? 24 : 20,
                            color: isSelected ? type.color : theme.hintColor,
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            type.label,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? type.color : theme.hintColor,
                              fontSize: isTablet ? 11 : 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
