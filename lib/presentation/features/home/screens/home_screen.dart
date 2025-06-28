import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/banner_carousel.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/campaign_posts_slide_show.dart';
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
      'title': 'Thông tin tuyển sinh Cao Thắng',
      'postId': 'post_1',
    },
    {
      'id': 2,
      'image': 'https://caothang.edu.vn/tuyensinh/images/banner/banner_2.png',
      'title': 'Hướng dẫn quy trình xét tuyển',
      'postId': 'post_2',
    },
    {
      'id': 3,
      'image':
          'https://caothang.edu.vn/tuyensinh/images/banner/Ketqua_HB_2025.png',
      'title': 'Kết quả học bổng năm 2025',
      'postId': 'post_3',
    },
  ],
);

final fullWidthImagesProvider = Provider<List<String>>(
  (ref) => [
    'https://scontent.fsgn2-10.fna.fbcdn.net/v/t39.30808-6/487600311_1179602907288175_4434940796596572504_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeE923gstMFLR90c3y74jYRFSHhAduegpzVIeEB256CnNSk8N4VkqYWc0Blh2wE0AVenpnMK8SW4-uPzqhxghMTP&_nc_ohc=sCDoF1ZJI9gQ7kNvwFH0cZ5&_nc_oc=Adn8EZl77SF2ll1n6iF6MyXppavJneHHGkFEMX59JmQmyXPNt5F8z6l5jIC4WHKs2ahDmkIJAji9UBqOk1g6oS-1&_nc_zt=23&_nc_ht=scontent.fsgn2-10.fna&_nc_gid=JysYFYjhgLwcat6lQ2OI9w&oh=00_AfOSteSHICk63nQ3dFP8UyxC1x3EZzSyneosPgx6KjkDHA&oe=6862091A',
    'https://scontent.fsgn2-3.fna.fbcdn.net/v/t39.30808-6/487312031_1178854607363005_4429200238628975026_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFd84ea2uAYtKyhj--1FSXgVXM__dqtZ0FVcz_92q1nQfgG9Z1XtalqBXbVNCYJYJQNAHbM9RLkJwATzTp-fUOt&_nc_ohc=gc3mAlds5t0Q7kNvwEmA6jU&_nc_oc=AdnzcrhP4lBksgfoXjNIEdQlB-QiZ-atzascMISN8BWxb9sDyT2jLvajPC8bxdmPOf-WRSvs72IW7Tq0mEz45v2h&_nc_zt=23&_nc_ht=scontent.fsgn2-3.fna&_nc_gid=mCZU8-JWHs-2vFWHFUQ6Gg&oh=00_AfP-9IlDuiB6aFWSpEHOBNfzV2KJu0QJ9ghHvgd145XqJw&oe=68620C4D',
    'https://scontent.fsgn2-7.fna.fbcdn.net/v/t39.30808-6/488534368_1179951383919994_4081001447821257097_n.jpg?stp=dst-jpg_s600x600_tt6&_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHbHizgHDEEHL7A9jawVY68BhTPD5rXGxwGFM8PmtcbHKd_hcCRxXk1fIVchN2L2ZNRkaShDzh6fysJ95CCAMhi&_nc_ohc=n2lAvPmlre0Q7kNvwEmD1TJ&_nc_oc=Adl7TvCVibDef5mqOl1E_oqA9fCIhFtPBWxopQIzJr4INAEZsxnlZ03aMylU4o52RaflX4fFR88be1FIFkkzwJJ0&_nc_zt=23&_nc_ht=scontent.fsgn2-7.fna&_nc_gid=pgFwb-j8QBIC2ePENJUaDQ&oh=00_AfMJznJ2kCHptYVmk2mXJC9RTkLhDNGpLaBWxiV2v3WHcQ&oe=686217A7',
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
