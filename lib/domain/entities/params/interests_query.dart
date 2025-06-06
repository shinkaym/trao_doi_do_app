import 'package:equatable/equatable.dart';

class InterestsQuery extends Equatable {
  final int page;
  final int limit;
  final String? sort;
  final String? order; // ASC, DESC
  final int?
  type; // 1: Interested (posts I'm interested in), 2: Following (posts interested in my posts)
  final String? search;

  const InterestsQuery({
    this.page = 1,
    this.limit = 10,
    this.sort,
    this.order,
    this.type,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};

    if (sort != null) params['sort'] = sort;
    if (order != null) params['order'] = order;
    if (type != null) params['type'] = type;
    if (search != null) params['search'] = search;

    return params;
  }

  InterestsQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    String? order,
    int? type,
    String? search,
  }) {
    return InterestsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      type: type ?? this.type,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [page, limit, sort, order, type, search];
}
