import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final ValueNotifier<int> currentImageIndex;

  const ImageGallery({
    super.key,
    required this.images,
    required this.pageController,
    required this.currentImageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: (index) {
            currentImageIndex.value = index;
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ValueListenableBuilder<int>(
            valueListenable: currentImageIndex,
            builder: (context, index, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: currentImageIndex,
              builder: (context, index, child) {
                return Row(
                  children:
                      images.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index == entry.key
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
      ],
    );
  }
}
