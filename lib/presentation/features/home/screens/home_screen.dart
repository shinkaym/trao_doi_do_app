import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/banner_carousel.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/campaign_posts_slide_show.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/contact_info_widget.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/features_list.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/full_width_images.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/post_category_section.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/college_links_section.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

final bannerSlidesProvider = Provider<List<Map<String, dynamic>>>(
  (ref) => [
    {
      'id': 1,
      'image': 'https://caothang.edu.vn/tuyensinh/images/banner/banner_1.png',
      'title': 'Trường Cao đẳng Kỹ thuật Cao Thắng',
      'url': 'https://caothang.edu.vn/',
    },
    {
      'id': 2,
      'image': 'https://caothang.edu.vn/tuyensinh/images/banner/banner_2.png',
      'title': 'Tìm hiểu về trường',
      'url': 'https://caothang.edu.vn/bai_viet/Gioi-thieu-1',
    },
    {
      'id': 3,
      'image':
          'https://caothang.edu.vn/tuyensinh/images/banner/Ketqua_HB_2025.png',
      'title': 'Thông tin tuyển sinh',
      'url': 'https://caothang.edu.vn/tuyensinh/',
    },
  ],
);

final fullWidthImagesProvider = Provider<List<String>>(
  (ref) => [
    '1.jpg',
    '2.jpg',
    '3.jpg',
  ],
);

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerSlides = ref.watch(bannerSlidesProvider);
    final features = FeatureType.allFeatures;
    final homePostTypes = PostType.allPostTypesWithoutCampaign;
    final fullWidthImages = ref.watch(fullWidthImagesProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return SmartScaffold(
      appBarType: AppBarType.standard,
      showSearchButton: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BannerCarousel(
                    bannerSlides: bannerSlides,
                    isTablet: isTablet,
                  ),

                  FeaturesList(
                    features: features,
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),

                  SizedBox(height: isTablet ? 32 : 24),

                  CollegeLinksSection(
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  CampaignPostsSlideshow(
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  // Phần 3: Danh sách các loại bài đăng - Có padding
                  ...homePostTypes.map(
                    (postType) => PostCategorySection(
                      postType: postType,
                      isTablet: isTablet,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ),

                  SizedBox(height: isTablet ? 32 : 24),

                  ContactInfoSection(
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  FullWidthImages(images: fullWidthImages, isTablet: isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
