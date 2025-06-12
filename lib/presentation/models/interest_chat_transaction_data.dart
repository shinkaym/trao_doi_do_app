import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestChatTransactionData {
  final InterestPost post;
  final bool isPostOwner;
  final List<InterestItem> items;

  InterestChatTransactionData({
    required this.post,
    required this.isPostOwner,
    required this.items,
  });
}
