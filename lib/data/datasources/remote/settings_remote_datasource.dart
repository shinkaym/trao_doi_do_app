import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/settings_response_model.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsResponseModel> getSettings();
  Future<SettingResponseModel> getSettingByKey(String settingKey);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final DioClient _dioClient;

  SettingsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<SettingsResponseModel> getSettings() async {
    final response = await _dioClient.get(
      ApiConstants.settings,
      // options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => SettingsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<SettingResponseModel> getSettingByKey(String settingKey) async {
    final response = await _dioClient.get(
      '${ApiConstants.settings}/$settingKey',
      // options: Options(extra: {'requiresAuth': false}),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) => SettingResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }
}
