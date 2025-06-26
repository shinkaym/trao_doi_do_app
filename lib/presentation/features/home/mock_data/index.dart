import 'package:hooks_riverpod/hooks_riverpod.dart';

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
