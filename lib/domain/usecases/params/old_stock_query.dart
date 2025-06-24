import 'package:equatable/equatable.dart';

class OldStockQuery extends Equatable {
  final int page;
  final int limit;
  final String? sort; // name column
  final String? order; // ASC/DESC
  final int? categoryID;
  final String? search;

  const OldStockQuery({
    this.page = 1,
    this.limit = 10,
    this.sort,
    this.order,
    this.categoryID,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};

    if (sort != null) params['sort'] = sort;
    if (order != null) params['order'] = order;
    if (categoryID != null) params['categoryID'] = categoryID;
    if (search != null) params['search'] = search;

    return params;
  }

  OldStockQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    int? categoryID,
    String? search,
  }) {
    return OldStockQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      categoryID: categoryID ?? this.categoryID,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [page, limit, sort, order, categoryID, search];
}
