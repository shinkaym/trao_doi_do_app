import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/core/services/fcm_service.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_fcm_token_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/save_fcm_token_usecase.dart';

class FcmState {
  final bool isLoading;
  final String? fcmToken;
  final Failure? failure;
  final String? successMessage;
  final bool isTokenRegistered;

  const FcmState({
    this.isLoading = false,
    this.fcmToken,
    this.failure,
    this.successMessage,
    this.isTokenRegistered = false,
  });

  FcmState copyWith({
    bool? isLoading,
    String? fcmToken,
    Failure? failure,
    String? successMessage,
    bool? isTokenRegistered,
    bool clearFailure = false,
    bool clearSuccessMessage = false,
  }) {
    return FcmState(
      isLoading: isLoading ?? this.isLoading,
      fcmToken: fcmToken ?? this.fcmToken,
      failure: clearFailure ? null : (failure ?? this.failure),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isTokenRegistered: isTokenRegistered ?? this.isTokenRegistered,
    );
  }
}

class FcmNotifier extends StateNotifier<FcmState> {
  final SaveFcmTokenUseCase _saveFcmTokenUseCase;
  final DeleteFcmTokenUseCase _deleteFcmTokenUseCase;
  final GetFcmTokenUseCase _getFcmTokenUseCase;

  FcmNotifier(
    this._saveFcmTokenUseCase,
    this._deleteFcmTokenUseCase,
    this._getFcmTokenUseCase,
  ) : super(const FcmState()) {
    _initializeFcm();
  }

  Future<void> _initializeFcm() async {
    await FcmService.initialize();
    await _loadLocalToken();
    await _registerFcmToken();
    _listenToTokenRefresh();
  }

  Future<void> _loadLocalToken() async {
    final result = await _getFcmTokenUseCase.execute();
    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (token) => state = state.copyWith(fcmToken: token),
    );
  }

  Future<void> _registerFcmToken() async {
    try {
      String? token = await FcmService.getFcmToken();
      if (token != null) {
        await _saveFcmToken(token);
      }
    } catch (e) {
      state = state.copyWith(failure: ServerFailure('Lỗi lấy FCM token: $e'));
    }
  }

  void _listenToTokenRefresh() {
    FcmService.onTokenRefresh((newToken) {
      _saveFcmToken(newToken);
    });
  }

  Future<void> _saveFcmToken(String token) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await _saveFcmTokenUseCase.execute(token);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
          isTokenRegistered: false,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          fcmToken: token,
          isTokenRegistered: true,
          successMessage: 'FCM token đã được đăng ký thành công',
        );
      },
    );
  }

  Future<void> deleteFcmToken() async {
    if (state.fcmToken == null) return;

    state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await _deleteFcmTokenUseCase.execute(state.fcmToken!);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          fcmToken: null,
          isTokenRegistered: false,
          successMessage: 'FCM token đã được xóa thành công',
        );
      },
    );
  }

  Future<void> refreshToken() async {
    await _registerFcmToken();
  }

  void clearError() {
    state = state.copyWith(clearFailure: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccessMessage: true);
  }
}
