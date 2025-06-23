import 'package:equatable/equatable.dart';

class OldStockQuery extends Equatable {
  final int page;
  final int limit;
  final String? sort; // name column
  final String? order; // ASC/DESC
  final String? searchBy;
  final String? searchValue;

  const OldStockQuery({
    this.page = 1,
    this.limit = 10,
    this.sort,
    this.order,
    this.searchBy,
    this.searchValue,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};

    if (sort != null) params['sort'] = sort;
    if (order != null) params['order'] = order;
    if (searchBy != null) params['searchBy'] = searchBy;
    if (searchValue != null) params['searchValue'] = searchValue;

    return params;
  }

  OldStockQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    String? searchBy,
    String? searchValue,
  }) {
    return OldStockQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      searchBy: searchBy ?? this.searchBy,
      searchValue: searchValue ?? this.searchValue,
    );
  }

  @override
  List<Object?> get props => [page, limit, sort, order, searchBy, searchValue];
}
