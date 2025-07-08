import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/update_appointment_usecase.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

// State cho appointment updates
class AppointmentState {
  final bool isLoading;
  final String? successMessage;
  final Failure? failure;
  final Map<int, bool>
  updatingAppointments; // Track which appointments are being updated

  const AppointmentState({
    this.isLoading = false,
    this.successMessage,
    this.failure,
    this.updatingAppointments = const {},
  });

  AppointmentState copyWith({
    bool? isLoading,
    String? successMessage,
    Failure? failure,
    Map<int, bool>? updatingAppointments,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
      failure: failure,
      updatingAppointments: updatingAppointments ?? this.updatingAppointments,
    );
  }

  // Helper method to check if specific appointment is updating
  bool isAppointmentUpdating(int appointmentID) {
    return updatingAppointments[appointmentID] ?? false;
  }
}

// Notifier cho appointment updates
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final UpdateAppointmentUseCase _updateAppointmentUseCase;

  AppointmentNotifier(this._updateAppointmentUseCase)
    : super(const AppointmentState());

  // Private method to handle update operations
  Future<void> _handleUpdate(
    int appointmentID,
    UpdateAppointment updateAppointment,
    String successMessage,
  ) async {
    // Check if this appointment is already being updated
    if (state.isAppointmentUpdating(appointmentID)) return;

    // Mark this appointment as updating
    final updatingMap = Map<int, bool>.from(state.updatingAppointments);
    updatingMap[appointmentID] = true;

    state = state.copyWith(
      isLoading: true,
      failure: null,
      successMessage: null,
      updatingAppointments: updatingMap,
    );

    try {
      final result = await _updateAppointmentUseCase(
        appointmentID,
        updateAppointment,
      );

      result.fold(
        (failure) {
          // Remove from updating map
          updatingMap.remove(appointmentID);
          state = state.copyWith(
            isLoading: false,
            failure: failure,
            updatingAppointments: updatingMap,
          );
        },
        (success) {
          // Remove from updating map
          updatingMap.remove(appointmentID);
          state = state.copyWith(
            isLoading: false,
            successMessage: successMessage,
            updatingAppointments: updatingMap,
          );
        },
      );
    } catch (e) {
      updatingMap.remove(appointmentID);
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
        updatingAppointments: updatingMap,
      );
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(int appointmentID, int status) async {
    final statusText = AppointmentStatus.fromValue(status).label;
    await _handleUpdate(
      appointmentID,
      UpdateAppointment(status: status),
      'Cập nhật trạng thái thành "$statusText" thành công',
    );
  }

  // Update full appointment
  Future<void> updateAppointment(
    int appointmentID,
    UpdateAppointment updateAppointment,
  ) async {
    await _handleUpdate(
      appointmentID,
      updateAppointment,
      'Cập nhật lịch hẹn thành công',
    );
  }

  // Cancel appointment (status = 4)
  Future<void> cancelAppointment(int appointmentID) async {
    await updateAppointmentStatus(appointmentID, 4);
  }

  // Clear messages and errors
  void clearMessages() {
    state = state.copyWith(successMessage: null, failure: null);
  }

  // Clear specific error
  void clearError() {
    state = state.copyWith(failure: null);
  }

  // Clear specific success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  // Reset state
  void reset() {
    state = const AppointmentState();
  }
}
