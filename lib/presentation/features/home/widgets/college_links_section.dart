import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class CollegeLinksSection extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const CollegeLinksSection({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  State<CollegeLinksSection> createState() => _CollegeLinksSectionState();
}

class _CollegeLinksSectionState extends State<CollegeLinksSection> {
  int _currentIndex = 0;

  static const List<CollegeLinkPreview> _universityLinks = [
    CollegeLinkPreview(
      title: 'Trường Cao đẳng Cao Thắng',
      description:
          'Trang chủ chính thức - Thông tin tuyển sinh, đào tạo và hoạt động của trường',
      url: 'https://caothang.edu.vn/',
      domain: 'caothang.edu.vn',
      color: Color(0xFF1976D2),
      iconData: Icons.school_outlined,
      imageUrl:
          'https://caothang.edu.vn/uploads/images/Tuyen_Sinh/ts_2025/PhanMemRieng_2025_16x9-min.jpg',
    ),
    CollegeLinkPreview(
      title: 'Khoa Công nghệ Thông tin',
      description:
          'Chuyên ngành CNTT - Lập trình, Mạng máy tính, An toàn thông tin',
      url: 'https://cntt.caothang.edu.vn/',
      domain: 'cntt.caothang.edu.vn',
      color: Color(0xFF388E3C),
      iconData: Icons.computer_outlined,
      imageUrl: 'https://cntt.caothang.edu.vn/uploads/media/default-slide.jpg',
    ),
    CollegeLinkPreview(
      title: 'Tuyển sinh 2024',
      description:
          'Thông tin tuyển sinh, hồ sơ xét tuyển và học bổng dành cho sinh viên',
      url: 'https://caothang.edu.vn/tuyensinh/',
      domain: 'caothang.edu.vn',
      color: Color(0xFFFF9800),
      iconData: Icons.assignment_ind_outlined,
      imageUrl:
          'https://caothang.edu.vn/tuyensinh/images/banner/Ketqua_HB_2025.png',
    ),
    CollegeLinkPreview(
      title: 'Trung tâm Anh ngữ Cao Thắng',
      description:
          'Khóa học tiếng Anh chất lượng cao - IELTS, TOEIC, Giao tiếp dành cho sinh viên',
      url: 'https://englishcenter.caothang.edu.vn/',
      domain: 'englishcenter.caothang.edu.vn',
      color: Color(0xFF7B1FA2),
      iconData: Icons.language_outlined,
      imageUrl:
          'https://englishcenter.caothang.edu.vn/images/banner/1710867119_420918217_927143358976996_3473896296539658367_n.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _SectionHeader(
            isTablet: widget.isTablet, 
            colorScheme: widget.colorScheme
          ),

          SizedBox(height: widget.isTablet ? 16 : 12),

          // Slideshow
          _buildSlideshow(),

          // Page indicators (chỉ hiển thị khi có > 1 link)
          if (_universityLinks.length > 1) ...[
            const SizedBox(height: 12),
            _buildPageIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildSlideshow() {
    return CarouselSlider.builder(
      itemCount: _universityLinks.length,
      itemBuilder: (context, index, realIndex) {
        final linkPreview = _universityLinks[index];
        return Container(
          width: MediaQuery.of(context).size.width,
          child: _LinkPreviewCard(
            linkPreview: linkPreview,
            isTablet: widget.isTablet,
            colorScheme: widget.colorScheme,
          ),
        );
      },
      options: CarouselOptions(
        height: widget.isTablet ? 180.0 : 140.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        viewportFraction: 1.0, // Full width
        enableInfiniteScroll: _universityLinks.length > 1,
        pauseAutoPlayOnTouch: true,
        pauseAutoPlayOnManualNavigate: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _universityLinks.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () {
            // Optional: Add controller to jump to specific page
          },
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == entry.key
                  ? widget.colorScheme.primary
                  : widget.colorScheme.outline.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.isTablet, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 8 : 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.link,
            color: Colors.white,
            size: isTablet ? 16 : 14,
          ),
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Text(
          'Liên kết trường học',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LinkPreviewCard extends StatefulWidget {
  final CollegeLinkPreview linkPreview;
  final bool isTablet;
  final ColorScheme colorScheme;

  const _LinkPreviewCard({
    required this.linkPreview,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<_LinkPreviewCard> createState() => _LinkPreviewCardState();
}

class _LinkPreviewCardState extends State<_LinkPreviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.isTablet ? 200.0 : 160.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _launchUrl(context, widget.linkPreview.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: cardHeight,
          margin: EdgeInsets.zero, // Remove margin for full width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.colorScheme.shadow.withOpacity(
                  _isHovered ? 0.2 : 0.1,
                ),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: widget.linkPreview.imageUrl != null
                      ? Image.network(
                          widget.linkPreview.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderBackground(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPlaceholderBackground();
                          },
                        )
                      : _buildPlaceholderBackground(),
                ),

                // Gradient Overlay - Đậm hơn để chữ rõ hơn
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Hover Effect Overlay
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.linkPreview.color.withOpacity(0.1),
                        border: Border.all(
                          color: widget.linkPreview.color.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                // Content Overlay
                Positioned(
                  left: widget.isTablet ? 20 : 16,
                  right: widget.isTablet ? 20 : 16,
                  bottom: widget.isTablet ? 20 : 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title - Chữ rõ hơn
                      Text(
                        widget.linkPreview.title,
                        style: TextStyle(
                          fontSize: widget.isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.8),
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 1,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: widget.isTablet ? 8 : 6),

                      // Description - Chữ rõ hơn
                      Text(
                        widget.linkPreview.description,
                        style: TextStyle(
                          fontSize: widget.isTablet ? 14 : 12,
                          color: Colors.white,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 1,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        maxLines: widget.isTablet ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: widget.isTablet ? 12 : 8),

                      // Domain và Icon - Đơn giản hóa
                      Row(
                        children: [
                          Icon(
                            widget.linkPreview.iconData,
                            size: widget.isTablet ? 16 : 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(width: widget.isTablet ? 8 : 6),
                          Expanded(
                            child: Text(
                              widget.linkPreview.domain,
                              style: TextStyle(
                                fontSize: widget.isTablet ? 12 : 11,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new,
                            size: widget.isTablet ? 16 : 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.linkPreview.color.withOpacity(0.4),
            widget.linkPreview.color.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.linkPreview.iconData,
          color: Colors.white.withOpacity(0.3),
          size: widget.isTablet ? 64 : 48,
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          context.showErrorSnackBar('Không thể mở liên kết: $url');
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Lỗi khi mở liên kết: $e');
      }
    }
  }
}

// Model class cho College Link Preview
class CollegeLinkPreview {
  final String title;
  final String description;
  final String url;
  final String domain;
  final Color color;
  final IconData iconData;
  final String? imageUrl;

  const CollegeLinkPreview({
    required this.title,
    required this.description,
    required this.url,
    required this.domain,
    required this.color,
    required this.iconData,
    this.imageUrl,
  });
}