import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/data/models/response/api_response_model.dart';
import 'package:trao_doi_do_app/data/models/response/notification_response_model.dart';
import 'package:trao_doi_do_app/domain/usecases/params/notification_query.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationsResponseModel> getNotifications(NotificationQuery query);
  Future<void> markNotificationAsRead(int notificationID);
  Future<void> markAllNotificationsAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<NotificationsResponseModel> getNotifications(
    NotificationQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiConstants.clientNotifications,
      queryParameters: query.toQueryParams(),
    );

    final result = ApiResponseModel.fromJson(
      response.data,
      (json) =>
          NotificationsResponseModel.fromJson(json as Map<String, dynamic>),
    );

    return result.data!;
  }

  @override
  Future<void> markNotificationAsRead(int notificationID) async {
    await _dioClient.patch(
      '${ApiConstants.clientNotifications}/$notificationID',
    );
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await _dioClient.patch(ApiConstants.clientNotifications);
  }
}
