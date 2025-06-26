import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/update_appointment_usecase.dart';

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
    final statusText = _getStatusText(status);
    await _handleUpdate(
      appointmentID,
      UpdateAppointment(status: status),
      'Cập nhật trạng thái thành "$statusText" thành công',
    );
  }

  // Update appointment time
  Future<void> updateAppointmentTime(
    int appointmentID,
    String? startTime,
    String? endTime,
  ) async {
    await _handleUpdate(
      appointmentID,
      UpdateAppointment(startTime: startTime, endTime: endTime),
      'Cập nhật thời gian lịch hẹn thành công',
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

  // Confirm appointment (status = 1)
  Future<void> confirmAppointment(int appointmentID) async {
    await updateAppointmentStatus(appointmentID, 1);
  }

  // Start appointment (status = 2)
  Future<void> startAppointment(int appointmentID) async {
    await updateAppointmentStatus(appointmentID, 2);
  }

  // Complete appointment (status = 3)
  Future<void> completeAppointment(int appointmentID) async {
    await updateAppointmentStatus(appointmentID, 3);
  }

  // Cancel appointment (status = 4)
  Future<void> cancelAppointment(int appointmentID) async {
    await updateAppointmentStatus(appointmentID, 4);
  }

  // Reschedule appointment
  Future<void> rescheduleAppointment(
    int appointmentID,
    String startTime,
    String endTime,
  ) async {
    await updateAppointmentTime(appointmentID, startTime, endTime);
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

  // Helper method to get status text
  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Đang thực hiện';
      case 3:
        return 'Hoàn thành';
      case 4:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  // Helper methods for validation
  bool canUpdateStatus(int currentStatus, int newStatus) {
    // Define allowed status transitions
    switch (currentStatus) {
      case 0: // Chờ xác nhận
        return [1, 4].contains(newStatus); // Có thể xác nhận hoặc hủy
      case 1: // Đã xác nhận
        return [2, 4].contains(newStatus); // Có thể bắt đầu hoặc hủy
      case 2: // Đang thực hiện
        return [3].contains(newStatus); // Chỉ có thể hoàn thành
      case 3: // Hoàn thành
        return false; // Không thể thay đổi
      case 4: // Đã hủy
        return false; // Không thể thay đổi
      default:
        return false;
    }
  }

  // Check if appointment can be updated
  bool canUpdateAppointment(int status) {
    return [
      0,
      1,
    ].contains(status); // Chỉ có thể cập nhật khi chờ xác nhận hoặc đã xác nhận
  }
}

// Providers
final updateAppointmentUseCaseProvider =
    Provider.autoDispose<UpdateAppointmentUseCase>((ref) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return UpdateAppointmentUseCase(repository);
    });

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      final updateAppointmentUseCase = ref.watch(
        updateAppointmentUseCaseProvider,
      );
      return AppointmentNotifier(updateAppointmentUseCase);
    });

// Computed providers for UI
final appointmentIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appointmentProvider).isLoading;
});

final appointmentErrorProvider = Provider<Failure?>((ref) {
  return ref.watch(appointmentProvider).failure;
});

final appointmentSuccessProvider = Provider<String?>((ref) {
  return ref.watch(appointmentProvider).successMessage;
});

