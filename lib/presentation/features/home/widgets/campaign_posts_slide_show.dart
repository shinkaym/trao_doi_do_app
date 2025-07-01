import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/usecases/params/post_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/skeleton_posts_slideshow.dart';

class CampaignPostsSlideshow extends HookConsumerWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const CampaignPostsSlideshow({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignPostsState = ref.watch(
      postsProviderFamily(PostType.campaign),
    );

    useEffect(() {
      if (campaignPostsState.posts.isEmpty && !campaignPostsState.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(postsProviderFamily(PostType.campaign).notifier)
              .loadPosts(
                newQuery: PostsQuery(
                  type: PostType.campaign.value!,
                  limit: 6, // Tăng limit cho campaign vì quan trọng
                  page: 1,
                  sort: 'createdAt',
                  order: 'DESC',
                ),
                refresh: true,
              );
        });
      }
      return null;
    }, []);

    // Nếu không có campaign nào, không hiển thị section
    if (campaignPostsState.posts.isEmpty && !campaignPostsState.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Header
          _CampaignHeader(
            isTablet: isTablet,
            colorScheme: colorScheme,
            onViewAll: () => _navigateToSearch(context),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Campaign Posts Slideshow
          if (campaignPostsState.isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 24 : 16),
              child: SkeletonPostsSlideshow(isTablet: isTablet, animated: true),
            )
          else if (campaignPostsState.posts.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 24 : 16),
              child: _CampaignSlideshow(
                campaigns: campaignPostsState.posts.take(5).toList(),
                isTablet: isTablet,
                colorScheme: colorScheme,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    context.pushNamed(RouteNames.posts, extra: {'type': PostType.campaign});
  }
}

class _CampaignHeader extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback onViewAll;

  const _CampaignHeader({
    required this.isTablet,
    required this.colorScheme,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Campaign Icon với gradient background
        Container(
          padding: EdgeInsets.all(isTablet ? 14 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PostType.campaign.color,
                PostType.campaign.color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: PostType.campaign.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            PostType.campaign.icon,
            color: Colors.white,
            size: isTablet ? 20 : 18,
          ),
        ),

        SizedBox(width: isTablet ? 16 : 12),

        // Title với đặc biệt styling cho campaign
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chiến dịch nổi bật',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tham gia các hoạt động ý nghĩa',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // View all button
        _CampaignActionButton(
          onPressed: onViewAll,
          isTablet: isTablet,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _CampaignActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet;
  final ColorScheme colorScheme;

  const _CampaignActionButton({
    required this.onPressed,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PostType.campaign.color,
                PostType.campaign.color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            boxShadow: [
              BoxShadow(
                color: PostType.campaign.color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Icon(
                Icons.arrow_forward_ios,
                size: isTablet ? 14 : 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignSlideshow extends StatefulWidget {
  final List<Post> campaigns;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _CampaignSlideshow({
    required this.campaigns,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  State<_CampaignSlideshow> createState() => _CampaignSlideshowState();
}

class _CampaignSlideshowState extends State<_CampaignSlideshow> {
  int _currentIndex = 0;
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel with enhanced styling for campaigns
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: widget.campaigns.length,
              itemBuilder: (context, index, realIndex) {
                final campaign = widget.campaigns[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: CampaignPostCard(
                    post: campaign,
                    isTablet: widget.isTablet,
                    colorScheme: widget.colorScheme,
                    theme: widget.theme,
                    onTap: (post) {
                      context.pushNamed(
                        'post-detail',
                        pathParameters: {'slug': post.slug.toString()},
                      );
                    },
                  ),
                );
              },
              options: CarouselOptions(
                height: widget.isTablet ? 250 : 200,
                autoPlay: true,
                autoPlayInterval: const Duration(
                  seconds: 5,
                ), // Longer interval for campaigns
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInOutCubic,
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                enableInfiniteScroll: widget.campaigns.length > 1,
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayOnManualNavigate: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),

        // Enhanced page indicators for campaigns
        if (widget.campaigns.length > 1) ...[
          SizedBox(height: widget.isTablet ? 16 : 12),
          _buildCampaignPageIndicator(),
        ],
      ],
    );
  }

  Widget _buildCampaignPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          widget.campaigns.asMap().entries.map((entry) {
            final isActive = _currentIndex == entry.key;
            return GestureDetector(
              onTap: () {
                _carouselController.animateToPage(entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width:
                    isActive
                        ? (widget.isTablet ? 24 : 20)
                        : (widget.isTablet ? 8 : 6),
                height: widget.isTablet ? 8 : 6,
                margin: EdgeInsets.symmetric(
                  horizontal: widget.isTablet ? 4 : 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color:
                      isActive
                          ? PostType.campaign.color
                          : widget.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// Specialized Campaign Post Card
class CampaignPostCard extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final void Function(Post)? onTap;

  const CampaignPostCard({
    super.key,
    required this.post,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(post) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: isTablet ? 250 : 200,
          child: Row(
            children: [
              // Campaign Image with special styling
              _CampaignImage(
                post: post,
                isTablet: isTablet,
                colorScheme: colorScheme,
                theme: theme,
              ),

              // Campaign Information
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCampaignHeader(),
                      _buildCampaignInfo(),
                      _buildCampaignFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campaign badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10 : 8,
            vertical: isTablet ? 4 : 3,
          ),
          decoration: BoxDecoration(
            color: PostType.campaign.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: PostType.campaign.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PostType.campaign.icon,
                size: isTablet ? 12 : 10,
                color: PostType.campaign.color,
              ),
              SizedBox(width: isTablet ? 4 : 3),
              Text(
                'CHIẾN DỊCH',
                style: TextStyle(
                  fontSize: isTablet ? 10 : 9,
                  fontWeight: FontWeight.bold,
                  color: PostType.campaign.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        // Title
        Text(
          post.title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCampaignInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.description,
          style: TextStyle(
            fontSize: isTablet ? 13 : 12,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isTablet ? 8 : 6),
        _buildCampaignDetails(),
      ],
    );
  }

  Widget _buildCampaignDetails() {
    // Parse campaign info from JSON
    final campaignInfo = _getCampaignInfoFromPost();

    return Column(
      children: [
        if (campaignInfo['location']?.isNotEmpty == true)
          _CampaignInfoChip(
            icon: Icons.location_on,
            text: campaignInfo['location']!,
            color: Colors.blue.shade700,
            backgroundColor: Colors.blue.withOpacity(0.1),
            isTablet: isTablet,
          ),
        if (campaignInfo['organizer']?.isNotEmpty == true)
          _CampaignInfoChip(
            icon: Icons.group,
            text: 'BTC: ${campaignInfo['organizer']}',
            color: Colors.green.shade700,
            backgroundColor: Colors.green.withOpacity(0.1),
            isTablet: isTablet,
          ),
      ],
    );
  }

  Widget _buildCampaignFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Interest count
        if (post.interestCount != null && post.interestCount! > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8 : 6,
              vertical: isTablet ? 4 : 3,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: isTablet ? 12 : 10,
                ),
                SizedBox(width: isTablet ? 4 : 3),
                Text(
                  '${post.interestCount} quan tâm',
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Time
        if (post.createdAt != null)
          Text(
            TimeUtils.formatTimeAgo(post.createdAt!),
            style: TextStyle(
              fontSize: isTablet ? 11 : 10,
              color: theme.hintColor,
            ),
          ),
      ],
    );
  }

  Map<String, String> _getCampaignInfoFromPost() {
    try {
      if (post.info.isNotEmpty) {
        final infoData = jsonDecode(post.info) as Map<String, dynamic>;
        return {
          'location': infoData['location']?.toString() ?? '',
          'organizer': infoData['organizer']?.toString() ?? '',
          'startDate': infoData['startDate']?.toString() ?? '',
          'endDate': infoData['endDate']?.toString() ?? '',
        };
      }
    } catch (e) {
      // Handle JSON parsing error
    }
    return {};
  }
}

class _CampaignImage extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _CampaignImage({
    required this.post,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 160 : 140,
      child: Stack(
        children: [
          // Main image with gradient overlay
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Stack(
              children: [
                post.images.isNotEmpty
                    ? _buildImage(post.images.first)
                    : _buildPlaceholder(),
                // Gradient overlay for better text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Campaign status badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PostType.campaign.color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'ĐANG DIỄN RA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 9 : 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageData) {
    if (imageData.startsWith('data:')) {
      try {
        final bytes = Base64Utils.decodeImageFromBase64(imageData);
        if (bytes != null) {
          return Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    return Image.network(
      imageData,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PostType.campaign.color.withOpacity(0.3),
            PostType.campaign.color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        PostType.campaign.icon,
        size: isTablet ? 40 : 32,
        color: PostType.campaign.color.withOpacity(0.7),
      ),
    );
  }
}

class _CampaignInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;
  final bool isTablet;

  const _CampaignInfoChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 4 : 3),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 12 : 10, color: color),
          SizedBox(width: isTablet ? 4 : 3),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
