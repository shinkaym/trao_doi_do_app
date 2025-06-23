import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';

class PostImageGallery extends HookWidget {
  final List<String> images;
  final PageController pageController;
  final ValueNotifier<int> currentImageIndex;

  const PostImageGallery({
    super.key,
    required this.images,
    required this.pageController,
    required this.currentImageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image Gallery
        PageView.builder(
          controller: pageController,
          onPageChanged: (index) {
            currentImageIndex.value = index;
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return _buildBase64Image(images[index]);
          },
        ),

        // Image Counter
        if (images.length > 1)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentImageIndex.value + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Image Dots Indicator
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...images.asMap().entries.map((entry) {
                      final isActive = currentImageIndex.value == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBase64Image(String base64String) {
    if (base64String.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(base64String);

      if (imageBytes != null) {
        return InteractiveViewer(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );
      }
    }

    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }
}