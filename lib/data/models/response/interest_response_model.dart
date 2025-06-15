import 'package:trao_doi_do_app/data/models/interest_model.dart';
import 'package:trao_doi_do_app/domain/entities/response/interest_response.dart';

class InterestsResponseModel {
  final List<InterestPostModel> interests;
  final int totalPage;

  const InterestsResponseModel({
    required this.interests,
    required this.totalPage,
  });

  factory InterestsResponseModel.fromJson(Map<String, dynamic> json) {
    return InterestsResponseModel(
      interests:
          (json['interests'] as List<dynamic>? ?? [])
              .map(
                (interest) => InterestPostModel.fromJson(
                  interest as Map<String, dynamic>,
                ),
              )
              .toList(),
      totalPage: json['totalPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'totalPage': totalPage,
    };
  }

  InterestsResponse toEntity() {
    return InterestsResponse(
      interests: interests.map((interest) => interest.toEntity()).toList(),
      totalPage: totalPage,
    );
  }

  factory InterestsResponseModel.fromEntity(InterestsResponse entity) {
    return InterestsResponseModel(
      interests:
          entity.interests
              .map((interest) => InterestPostModel.fromEntity(interest))
              .toList(),
      totalPage: entity.totalPage,
    );
  }
}

class InterestActionResponseModel {
  final int interestID;

  const InterestActionResponseModel({required this.interestID});

  factory InterestActionResponseModel.fromJson(Map<String, dynamic> json) {
    return InterestActionResponseModel(interestID: json['interestID'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'interestID': interestID};
  }

  InterestActionResponse toEntity(String message) {
    return InterestActionResponse(interestID: interestID, message: message);
  }
}
