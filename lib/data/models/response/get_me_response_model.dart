import 'package:trao_doi_do_app/data/models/user_model.dart';

class GetMeResponseModel {
  final UserModel user;

  const GetMeResponseModel({required this.user});

  factory GetMeResponseModel.fromJson(Map<String, dynamic> json) {
    return GetMeResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }
}
