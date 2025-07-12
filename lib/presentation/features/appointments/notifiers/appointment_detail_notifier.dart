import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointment_detail_usecase.dart';

class AppointmentDetailState {
  final bool isLoading;
  final Appointment? appointmentDetail;
  final Failure? failure;

  AppointmentDetailState({
    this.isLoading = false,
    this.appointmentDetail,
    this.failure,
  });

  AppointmentDetailState copyWith({
    bool? isLoading,
    Appointment? appointmentDetail,
    Failure? failure,
  }) {
    return AppointmentDetailState(
      isLoading: isLoading ?? this.isLoading,
      appointmentDetail: appointmentDetail ?? this.appointmentDetail,
      failure: failure,
    );
  }
}

class AppointmentDetailNotifier extends StateNotifier<AppointmentDetailState> {
  final GetAppointmentDetailUseCase _getAppointmentDetailUseCase;

  AppointmentDetailNotifier(this._getAppointmentDetailUseCase)
    : super(AppointmentDetailState());

  Future<void> loadAppointmentDetail(int appointmentID) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, failure: null);

    try {
      final result = await _getAppointmentDetailUseCase(appointmentID);

      result.fold(
        (failure) => state = state.copyWith(isLoading: false, failure: failure),
        (appointmentDetail) =>
            state = state.copyWith(
              isLoading: false,
              appointmentDetail: appointmentDetail,
              failure: null,
            ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
    }
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }

  void reset() {
    state = AppointmentDetailState();
  }
}
