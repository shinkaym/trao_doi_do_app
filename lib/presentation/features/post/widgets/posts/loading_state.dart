import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/loading_card.dart';

class LoadingState extends StatelessWidget {
  final bool isTablet;
  final Size screenSize;
  final ColorScheme colorScheme;

  const LoadingState({
    super.key,
    required this.isTablet,
    required this.screenSize,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: isTablet ? 16 : 8,
      ),
      itemCount: 5,
      itemBuilder: (context, index) => LoadingCard(
        isTablet: isTablet,
        screenSize: screenSize,
        colorScheme: colorScheme,
      ),
    );
  }
}
