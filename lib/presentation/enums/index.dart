import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';

enum AppBarType {
  standard, // CustomAppBar thường với notification
  detail, // SliverAppBar cho detail screens
  chat, // AppBar riêng cho chat
  minimal, // AppBar đơn giản không có notification
}

// Enum cho loại bài đăng
enum PostType {
  all('Tất cả', Icons.list, null),
  giveAway('Tặng đồ', Icons.volunteer_activism, 1),
  foundItem('Tôi nhặt được đồ', Icons.help_outline, 2),
  findLost('Tôi bị mất đồ', Icons.search, 3),
  wantItem('Muốn nhận đồ cũ', Icons.shopping_bag, 4),
  campaign('Chiến dịch', Icons.campaign, 5),
  freePost('Bài viết', Icons.edit_note, 6);

  const PostType(this.label, this.icon, this.value);

  final String label;
  final IconData icon;
  final int? value;

  /// Màu sắc tương ứng
  Color get color {
    switch (this) {
      case PostType.giveAway:
        return Colors.blue;
      case PostType.foundItem:
        return Colors.green;
      case PostType.findLost:
        return Colors.red;
      case PostType.wantItem:
        return Colors.orange;
      case PostType.campaign:
        return Colors.teal;
      case PostType.freePost:
        return Colors.purple;
      case PostType.all:
        return Colors.grey;
    }
  }

  static PostType fromValue(int value) {
    return PostType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PostType.all,
    );
  }

  static List<PostType> get allPostTypes => [
    PostType.giveAway,
    PostType.foundItem,
    PostType.findLost,
    PostType.wantItem,
    PostType.campaign,
    PostType.freePost,
  ];

  /// Tất cả các loại post không bao gồm campaign
  static List<PostType> get allPostTypesWithoutCampaign => [
    PostType.giveAway,
    PostType.foundItem,
    PostType.findLost,
    PostType.wantItem,
    PostType.freePost,
  ];

  /// Tất cả các loại post với campaign ở đầu tiên
  static List<PostType> get allPostTypesWithCampaignFirst => [
    PostType.campaign,
    PostType.giveAway,
    PostType.foundItem,
    PostType.findLost,
    PostType.wantItem,
    PostType.freePost,
  ];
}

// Enum cho trạng thái bài post
enum PostStatus {
  all('Tất cả', Icons.list, null),
  pending('Đang chờ duyệt', Icons.hourglass_empty, 1),
  rejected('Đã từ chối', Icons.block, 2),
  approved('Đã duyệt', Icons.check_circle, 3),
  locked('Đã khóa', Icons.lock, 4);

  const PostStatus(this.label, this.icon, this.value);

  final String label;
  final IconData icon;
  final int? value;

  static PostStatus fromValue(int value) {
    return PostStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PostStatus.all,
    );
  }

  Color get color {
    switch (this) {
      case PostStatus.pending:
        return Colors.orange;
      case PostStatus.rejected:
        return Colors.red;
      case PostStatus.approved:
        return Colors.green;
      case PostStatus.locked:
        return Colors.blueGrey;
      case PostStatus.all:
        return Colors.grey;
    }
  }
}

// Enum cho sắp xếp thời gian
enum SortOrder {
  newest('Mới nhất', Icons.arrow_downward, 'createdAt', 'DESC'),
  oldest('Cũ nhất', Icons.arrow_upward, 'createdAt', 'ASC'),
  quantityAsc('Số lượng tăng dần', Icons.arrow_upward, 'quantity', 'ASC'),
  quantityDesc('Số lượng giảm dần', Icons.arrow_downward, 'quantity', 'DESC'),
  startTimeAsc(
    'Thời gian lịch hẹn tăng dần',
    Icons.arrow_upward,
    'startTime',
    'ASC',
  ),
  startTimeDesc(
    'Thời gian lịch hẹn giảm dần',
    Icons.arrow_downward,
    'startTime',
    'DESC',
  );

  const SortOrder(this.label, this.icon, this.sort, this.order);
  final String label;
  final IconData icon;
  final String sort;
  final String order;

  static List<SortOrder> get timeSortOptions => [
    SortOrder.newest,
    SortOrder.oldest,
  ];

  static List<SortOrder> get quantitySortOptions => [
    SortOrder.quantityAsc,
    SortOrder.quantityDesc,
  ];

  static List<SortOrder> get startTimeSortOptions => [
    SortOrder.startTimeAsc,
    SortOrder.startTimeDesc,
  ];

  static List<SortOrder> get allTimeSortOptions => [
    ...timeSortOptions,
    ...startTimeSortOptions,
  ];
}

enum TransactionStatus {
  pending('Đang trong giao dịch', Icons.pending, Colors.orange, 1),
  accepted('Hoàn tất', Icons.check_circle, Colors.green, 2),
  rejected('Đã từ chối', Icons.cancel, Colors.red, 3),
  failed(
    'Giao dịch thất bại',
    Icons.error,
    Color(0xFFD32F2F),
    4,
  ), // red.shade700
  unknown('Không xác định', Icons.help, Colors.grey, 0);

  const TransactionStatus(this._label, this.icon, this.color, this.value);

  final String _label;
  final IconData icon;
  final Color color;
  final int value;

  /// Lấy label mặc định
  String get label => _label;

  /// Trả về label tùy thuộc chủ bài viết
  String getLabel({required bool isPostOwner}) {
    switch (this) {
      case TransactionStatus.rejected:
        return isPostOwner ? 'Đã từ chối' : 'Đã bị từ chối';
      case TransactionStatus.pending:
        return 'Đang trong giao dịch';
      default:
        return _label;
    }
  }

  static TransactionStatus fromValue(int value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.unknown,
    );
  }
}

enum InterestAction { create, cancel }

enum DeliveryMethod {
  meetInPerson('Gặp trực tiếp'),
  delivery('Giao hàng');

  const DeliveryMethod(this.displayName);
  final String displayName;

  String get value {
    switch (this) {
      case DeliveryMethod.meetInPerson:
        return 'Gặp trực tiếp';
      case DeliveryMethod.delivery:
        return 'Giao hàng';
    }
  }
}

enum FeatureType {
  createPost(
    'Đăng bài',
    Icons.add_circle_outline,
    Colors.blue,
    RouteNames.createPost,
  ),
  inventory(
    'Kho đồ cũ',
    Icons.inventory_2_outlined,
    Colors.green,
    RouteNames.warehouse,
  ),
  ranking(
    'Bảng xếp hạng',
    Icons.leaderboard_outlined,
    Colors.orange,
    RouteNames.ranking,
  ),
  favorites(
    'Quan tâm',
    Icons.favorite_outline,
    Colors.red,
    RouteNames.interests,
  );

  const FeatureType(this.title, this.icon, this.color, this.route);

  final String title;
  final IconData icon;
  final Color color;
  final String route;

  /// Lấy tất cả features
  static List<FeatureType> get allFeatures => FeatureType.values;
}

enum AppointmentStatus {
  scheduled('Đã hẹn', Icons.schedule, Colors.blue, 1),
  rejected('Đã từ chối', Icons.cancel, Colors.red, 2);

  const AppointmentStatus(this.label, this.icon, this.color, this.value);

  final String label;
  final IconData icon;
  final Color color;
  final int value;

  static AppointmentStatus fromValue(int value) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }

  /// Lấy tất cả appointment statuses
  static List<AppointmentStatus> get allStatuses => AppointmentStatus.values;
}

enum GoodDeedType {
  giveOldItems('Tặng đồ cũ', Icons.volunteer_activism, Colors.blue, 1),
  returnLostItems('Trả đồ thất lạc', Icons.restore, Colors.green, 2),
  joinCampaign('Tham gia chiến dịch', Icons.campaign, Colors.teal, 3);

  const GoodDeedType(this.label, this.icon, this.color, this.value);

  final String label;
  final IconData icon;
  final Color color;
  final int value;

  static GoodDeedType fromValue(int value) {
    return GoodDeedType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GoodDeedType.giveOldItems,
    );
  }

  /// Lấy tất cả good deed types
  static List<GoodDeedType> get allTypes => GoodDeedType.values;
}
