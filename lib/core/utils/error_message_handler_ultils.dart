import 'package:trao_doi_do_app/core/error/failure.dart';

class ErrorMessageHandler {
  // Private constructor để implement Singleton pattern
  ErrorMessageHandler._();
  static final ErrorMessageHandler _instance = ErrorMessageHandler._();
  static ErrorMessageHandler get instance => _instance;

  /// Chuyển đổi Failure thành message lỗi user-friendly
  String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return _handleServerFailure(failure as ServerFailure);
      case NetworkFailure:
        return _handleNetworkFailure(failure as NetworkFailure);
      case CacheFailure:
        return _handleCacheFailure(failure as CacheFailure);
      case ValidationFailure:
        return _handleValidationFailure(failure as ValidationFailure);
      default:
        return _getDefaultErrorMessage();
    }
  }

  /// Xử lý lỗi từ server
  String _handleServerFailure(ServerFailure failure) {
    if (failure.statusCode != null) {
      switch (failure.statusCode) {
        case 400:
          return _getBadRequestMessage(failure.message);
        case 401:
          final msg = failure.message.toLowerCase();
          if (msg.contains('email')) {
            return 'Email hoặc mật khẩu không chính xác.';
          }
          return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        case 403:
          return 'Bạn không có quyền thực hiện hành động này.';
        case 404:
          return 'Không tìm thấy thông tin yêu cầu.';
        case 422:
          return _getValidationErrorMessage(failure.message);
        case 429:
          return 'Bạn đã thực hiện quá nhiều yêu cầu. Vui lòng thử lại sau.';
        case 500:
          return 'Lỗi hệ thống. Vui lòng thử lại sau.';
        case 502:
        case 503:
        case 504:
          return 'Hệ thống đang bảo trì. Vui lòng thử lại sau.';
        default:
          return _getServerErrorMessage(failure.message);
      }
    }
    return _getServerErrorMessage(failure.message);
  }

  /// Xử lý lỗi mạng
  String _handleNetworkFailure(NetworkFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'Kết nối mạng chậm. Vui lòng thử lại.';
    }

    if (message.contains('no internet') ||
        message.contains('network unreachable')) {
      return 'Không có kết nối internet. Vui lòng kiểm tra mạng.';
    }

    if (message.contains('connection refused') ||
        message.contains('failed to connect')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
    }

    return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
  }

  /// Xử lý lỗi cache
  String _handleCacheFailure(CacheFailure failure) {
    return 'Lỗi lưu trữ dữ liệu. Vui lòng thử lại.';
  }

  /// Xử lý lỗi validation
  String _handleValidationFailure(ValidationFailure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
  }

  /// Xử lý message lỗi Bad Request (400)
  String _getBadRequestMessage(String originalMessage) {
    final message = originalMessage.toLowerCase();

    // Authentication related errors
    if (message.contains('invalid credentials') ||
        message.contains('wrong password') ||
        message.contains('incorrect password')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }

    if (message.contains('user not found') ||
        message.contains('email not found')) {
      return 'Không tìm thấy tài khoản với email này.';
    }

    if (message.contains('email already exists') ||
        message.contains('email taken')) {
      return 'Email này đã được sử dụng. Vui lòng chọn email khác.';
    }

    if (message.contains('weak password') ||
        message.contains('password too short')) {
      return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
    }

    // General validation errors
    if (message.contains('required field') ||
        message.contains('missing field')) {
      return 'Vui lòng điền đầy đủ thông tin bắt buộc.';
    }

    if (message.contains('invalid format') ||
        message.contains('invalid email')) {
      return 'Định dạng dữ liệu không hợp lệ.';
    }

    return originalMessage.isNotEmpty
        ? originalMessage
        : 'Yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
  }

  /// Xử lý message lỗi Validation (422)
  String _getValidationErrorMessage(String originalMessage) {
    // Parse validation errors from server response
    if (originalMessage.isNotEmpty) {
      return originalMessage;
    }
    return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin nhập vào.';
  }

  /// Xử lý message lỗi server chung
  String _getServerErrorMessage(String originalMessage) {
    if (originalMessage.isNotEmpty) {
      return originalMessage;
    }
    return 'Có lỗi xảy ra từ máy chủ. Vui lòng thử lại sau.';
  }

  /// Message lỗi mặc định
  String _getDefaultErrorMessage() {
    return 'Có lỗi không xác định xảy ra. Vui lòng thử lại.';
  }

  /// Các message lỗi phổ biến khác
  static const Map<String, String> commonErrors = {
    // Auth errors
    'email_not_verified':
        'Email chưa được xác thực. Vui lòng kiểm tra hộp thư.',
    'account_disabled': 'Tài khoản của bạn đã bị vô hiệu hóa.',
    'account_locked': 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.',
    'session_expired': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',

    // File upload errors
    'file_too_large': 'Tệp quá lớn. Vui lòng chọn tệp nhỏ hơn.',
    'invalid_file_type': 'Loại tệp không được hỗ trợ.',
    'upload_failed': 'Tải lên thất bại. Vui lòng thử lại.',

    // General errors
    'operation_failed': 'Thao tác thất bại. Vui lòng thử lại.',
    'data_not_found': 'Không tìm thấy dữ liệu.',
    'permission_denied': 'Bạn không có quyền thực hiện hành động này.',
    'rate_limit_exceeded':
        'Bạn đã thực hiện quá nhiều yêu cầu. Vui lòng thử lại sau.',
  };

  /// Lấy message lỗi từ error code
  String getMessageByCode(String errorCode) {
    return commonErrors[errorCode] ?? _getDefaultErrorMessage();
  }
}

/// Helper function để sử dụng dễ dàng hơn trong code
String getErrorMessage(Failure failure) {
  return ErrorMessageHandler.instance.getErrorMessage(failure);
}

/// Helper function để lấy message theo error code
String getErrorMessageByCode(String errorCode) {
  return ErrorMessageHandler.instance.getMessageByCode(errorCode);
}
