import 'package:equatable/equatable.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';

class InterestsResponse extends Equatable {
  final List<InterestPost> interests;
  final int totalPage;

  const InterestsResponse({required this.interests, required this.totalPage});

  @override
  List<Object?> get props => [interests, totalPage];
}

class InterestActionResponse extends Equatable {
  final int interestID;
  final String message;

  const InterestActionResponse({
    required this.interestID,
    required this.message,
  });

  @override
  List<Object?> get props => [interestID, message];
}
