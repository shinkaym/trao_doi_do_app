class ApiResponseModel<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponseModel({required this.code, required this.message, this.data});

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : null,
    );
  }
}
