import 'package:equatable/equatable.dart';

class MessagesQuery extends Equatable {
  final int interestID;
  final int page;
  final int limit;
  final String? search;

  const MessagesQuery({
    required this.interestID,
    this.page = 1,
    this.limit = 30,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'interestID': interestID,
      'page': page,
      'limit': limit,
    };

    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }

    return params;
  }

  MessagesQuery copyWith({
    int? interestID,
    int? page,
    int? limit,
    String? search,
  }) {
    return MessagesQuery(
      interestID: interestID ?? this.interestID,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [interestID, page, limit, search];
}
