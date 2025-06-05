import 'package:equatable/equatable.dart';

class PostsQuery extends Equatable {
  final int page;
  final int limit;
  final String? sort;
  final String? order; // ASC, DESC
  final int? status; // 1: Pending, 2: Rejected, 3: Approved
  final int? type; // 1: giveAway, 2: foundItem, 3: findLost, 4: freePost
  final String? searchBy;
  final String? searchValue;

  const PostsQuery({
    this.page = 1,
    this.limit = 10,
    this.sort,
    this.order,
    this.status,
    this.type,
    this.searchBy,
    this.searchValue,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};

    if (sort != null) params['sort'] = sort;
    if (order != null) params['order'] = order;
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    if (searchBy != null) params['searchBy'] = searchBy;
    if (searchValue != null) params['searchValue'] = searchValue;

    return params;
  }

  PostsQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    int? status,
    int? type,
    String? searchBy,
    String? searchValue,
  }) {
    return PostsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      status: status ?? this.status,
      type: type ?? this.type,
      searchBy: searchBy ?? this.searchBy,
      searchValue: searchValue ?? this.searchValue,
    );
  }

  @override
  List<Object?> get props => [
    page,
    limit,
    sort,
    order,
    status,
    type,
    searchBy,
    searchValue,
  ];
}
