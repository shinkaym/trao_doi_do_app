import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/shimmer.dart';

class LoadingCard extends StatelessWidget {
  final bool isTablet;
  final Size screenSize;
  final ColorScheme colorScheme;

  const LoadingCard({
    super.key,
    required this.isTablet,
    required this.screenSize,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Shimmer(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 24 : 20,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  Shimmer(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 16 : 14,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Shimmer(
                width: double.infinity,
                height: isTablet ? 20 : 18,
                colorScheme: colorScheme,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Shimmer(
                width: screenSize.width * 0.7,
                height: isTablet ? 20 : 18,
                colorScheme: colorScheme,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Shimmer(
                width: double.infinity,
                height: isTablet ? 16 : 14,
                colorScheme: colorScheme,
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Shimmer(
                width: double.infinity,
                height: isTablet ? 16 : 14,
                colorScheme: colorScheme,
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Shimmer(
                width: screenSize.width * 0.5,
                height: isTablet ? 16 : 14,
                colorScheme: colorScheme,
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Row(
                children: [
                  Shimmer(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 14 : 12,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  Shimmer(
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 20 : 16,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
