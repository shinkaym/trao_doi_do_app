import 'package:hooks_riverpod/hooks_riverpod.dart';

final bannerSlidesProvider = Provider<List<Map<String, dynamic>>>(
  (ref) => [
    {
      'id': 1,
      'image': 'https://caothang.edu.vn/tuyensinh/images/banner/banner_1.png',
      'title': 'Tặng đồ chơi cho trẻ em',
      'postId': 'post_1',
    },
    {
      'id': 2,
      'image': 'https://caothang.edu.vn/tuyensinh/images/banner/banner_2.png',
      'title': 'Nhặt được điện thoại',
      'postId': 'post_2',
    },
    {
      'id': 3,
      'image':
          'https://caothang.edu.vn/tuyensinh/images/banner/Ketqua_HB_2025.png',
      'title': 'Mất ví ở khu vực Quận 1',
      'postId': 'post_3',
    },
  ],
);
