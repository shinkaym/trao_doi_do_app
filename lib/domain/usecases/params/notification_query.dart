import 'package:equatable/equatable.dart';

class NotificationQuery extends Equatable {
  final int page;
  final int limit;

  const NotificationQuery({this.page = 1, this.limit = 10});

  Map<String, dynamic> toQueryParams() {
    return {'page': page, 'limit': limit};
  }

  NotificationQuery copyWith({int? page, int? limit}) {
    return NotificationQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [page, limit];
}
