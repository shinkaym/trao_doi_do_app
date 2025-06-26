import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/post_category_section.dart';

class SkeletonPostsSlideshow extends StatelessWidget {
  final bool isTablet;
  final bool animated;

  const SkeletonPostsSlideshow({
    Key? key,
    required this.isTablet,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel skeleton
        SizedBox(
          height: isTablet ? 180 : 150,
          child: CarouselSlider.builder(
            itemCount: 3,
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: SkeletonPostCard(isTablet: isTablet, animated: animated),
              );
            },
            options: CarouselOptions(
              height: isTablet ? 180 : 150,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
              autoPlay: false,
            ),
          ),
        ),

        // Page indicators skeleton
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class SkeletonPostCard extends StatelessWidget {
  final bool isTablet;
  final bool animated;

  const SkeletonPostCard({
    Key? key,
    required this.isTablet,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: isTablet ? 160 : 140,
        child: Row(
          children: [
            // Left side - Image skeleton
            _buildImageSkeleton(),

            // Right side - Information skeleton
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and description skeleton
                    _buildTitleAndDescriptionSkeleton(context),

                    // Location and reward skeleton
                    _buildLocationAndRewardSkeleton(),

                    // Time skeleton
                    _buildTimeSkeleton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSkeleton() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      child:
          animated
              ? AnimatedSkeletonContainer(
                width: isTablet ? 140 : 120,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              )
              : SkeletonContainer(
                width: isTablet ? 140 : 120,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
    );
  }

  Widget _buildTitleAndDescriptionSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title skeleton
        animated
            ? AnimatedSkeletonContainer(
              width: double.infinity,
              height: isTablet ? 15 : 13,
              borderRadius: BorderRadius.circular(4),
            )
            : SkeletonContainer(
              width: double.infinity,
              height: isTablet ? 15 : 13,
              borderRadius: BorderRadius.circular(4),
            ),

        SizedBox(height: isTablet ? 6 : 4),

        // Description skeleton (2 lines)
        animated
            ? AnimatedSkeletonContainer(
              width: double.infinity,
              height: isTablet ? 12 : 11,
              borderRadius: BorderRadius.circular(4),
            )
            : SkeletonContainer(
              width: double.infinity,
              height: isTablet ? 12 : 11,
              borderRadius: BorderRadius.circular(4),
            ),

        SizedBox(height: isTablet ? 3 : 2),

        animated
            ? AnimatedSkeletonContainer(
              width: MediaQuery.of(context).size.width * 0.6,
              height: isTablet ? 12 : 11,
              borderRadius: BorderRadius.circular(4),
            )
            : SkeletonContainer(
              width: 150,
              height: isTablet ? 12 : 11,
              borderRadius: BorderRadius.circular(4),
            ),
      ],
    );
  }

  Widget _buildLocationAndRewardSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location chip skeleton
        animated
            ? AnimatedSkeletonContainer(
              width: 100,
              height: isTablet ? 20 : 18,
              borderRadius: BorderRadius.circular(6),
            )
            : SkeletonContainer(
              width: 100,
              height: isTablet ? 20 : 18,
              borderRadius: BorderRadius.circular(6),
            ),

        SizedBox(height: isTablet ? 4 : 3),

        // Reward chip skeleton
        animated
            ? AnimatedSkeletonContainer(
              width: 80,
              height: isTablet ? 20 : 18,
              borderRadius: BorderRadius.circular(6),
            )
            : SkeletonContainer(
              width: 80,
              height: isTablet ? 20 : 18,
              borderRadius: BorderRadius.circular(6),
            ),
      ],
    );
  }

  Widget _buildTimeSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        animated
            ? AnimatedSkeletonContainer(
              width: 60,
              height: isTablet ? 10 : 9,
              borderRadius: BorderRadius.circular(4),
            )
            : SkeletonContainer(
              width: 60,
              height: isTablet ? 10 : 9,
              borderRadius: BorderRadius.circular(4),
            ),
      ],
    );
  }
}
