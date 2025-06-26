import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class FeaturesList extends StatefulWidget {
  final List<FeatureType> features;
  final bool isTablet;
  final ColorScheme colorScheme;

  const FeaturesList({
    super.key,
    required this.features,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<FeaturesList> createState() => _FeaturesListState();
}

class _FeaturesListState extends State<FeaturesList> {
  int _currentIndex = 0;
  late List<List<FeatureType>> _featurePages;

  @override
  void initState() {
    super.initState();
    _featurePages = _createFeaturePages();
  }

  List<List<FeatureType>> _createFeaturePages() {
    List<List<FeatureType>> pages = [];
    for (int i = 0; i < widget.features.length; i += 4) {
      int end =
          (i + 4 < widget.features.length) ? i + 4 : widget.features.length;
      pages.add(widget.features.sublist(i, end));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    if (_featurePages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _featurePages.length,
          itemBuilder: (context, index, realIndex) {
            return _buildFeaturePage(_featurePages[index]);
          },
          options: CarouselOptions(
            height: widget.isTablet ? 120 : 100,
            viewportFraction: 1.0, // Full width như banner
            enableInfiniteScroll: _featurePages.length > 1,
            autoPlay: false,
            enlargeCenterPage: false, // Tắt việc phóng to slide ở giữa
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        if (_featurePages.length > 1) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ],
      ],
    );
  }

  Widget _buildFeaturePage(List<FeatureType> pageFeatures) {
    return Container(
      width: MediaQuery.of(context).size.width, // Full width như banner
      // Loại bỏ margin horizontal để full width
      padding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 24 : 16, // Chuyển margin thành padding
        vertical: widget.isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(0), // Có thể để 0 hoặc giá trị nhỏ
        border: Border.all(
          color: widget.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            pageFeatures
                .map(
                  (feature) => Expanded(
                    child: _FeatureItem(
                      feature: feature,
                      isTablet: widget.isTablet,
                      colorScheme: widget.colorScheme,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _featurePages.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // Có thể thêm controller để jump to page nếu cần
              },
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == entry.key
                          ? widget.colorScheme.primary
                          : widget.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final FeatureType feature;
  final bool isTablet;
  final ColorScheme colorScheme;

  const _FeatureItem({
    required this.feature,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(feature.route);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 8 : 4, // Giảm padding horizontal cho mobile
          vertical: isTablet ? 12 : 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                feature.icon,
                size: isTablet ? 20 : 16,
                color: feature.color,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              feature.title,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}