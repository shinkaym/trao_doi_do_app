import 'package:equatable/equatable.dart';

class TransactionsQuery extends Equatable {
  final int page;
  final int limit;
  final String? sort;
  final String? order; // ASC, DESC
  final int? status; // 1: Pending, 2: Success, 3: Cancelled
  final int? postID;
  final String? searchBy;
  final String? searchValue;

  const TransactionsQuery({
    this.page = 1,
    this.limit = 10,
    this.sort,
    this.order,
    this.status,
    this.postID,
    this.searchBy,
    this.searchValue,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};

    if (sort != null) params['sort'] = sort;
    if (order != null) params['order'] = order;
    if (status != null) params['status'] = status;
    if (postID != null) params['postID'] = postID;
    if (searchBy != null) params['searchBy'] = searchBy;
    if (searchValue != null) params['searchValue'] = searchValue;

    return params;
  }

  TransactionsQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    int? status,
    int? postID,
    String? searchBy,
    String? searchValue,
  }) {
    return TransactionsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      status: status ?? this.status,
      postID: postID ?? this.postID,
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
    searchBy,
    searchValue,
  ];
}
