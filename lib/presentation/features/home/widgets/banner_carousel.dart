import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> bannerSlides;
  final bool isTablet;

  const BannerCarousel({
    super.key,
    required this.bannerSlides,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: bannerSlides.length,
        itemBuilder: (context, index, realIndex) {
          final slide = bannerSlides[index];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              // Loại bỏ margin horizontal để full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  0,
                ), // Có thể để 0 hoặc giá trị nhỏ
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  0,
                ), // Có thể để 0 hoặc giá trị nhỏ
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      slide['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: isTablet ? 60 : 50,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                Text(
                                  'Không thể tải ảnh',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                    // Title text
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isTablet ? 8 : 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 8,
                                vertical: isTablet ? 6 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: isTablet ? 240 : 200,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false, // Tắt việc phóng to slide ở giữa
          viewportFraction: 1.0, // Đặt thành 1.0 để full width
          enableInfiniteScroll: true,
          pauseAutoPlayOnTouch: true,
          pauseAutoPlayOnManualNavigate: true,
        ),
      ),
    );
  }
}
