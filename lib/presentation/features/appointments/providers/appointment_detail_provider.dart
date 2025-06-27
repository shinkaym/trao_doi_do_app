import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointment_detail_usecase.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

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

  // Helper method to get appointment status text
  String getStatusText() {
    if (state.appointmentDetail == null) return 'Không xác định';

    switch (state.appointmentDetail!.status) {
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

  // Helper method to get status color
  String getStatusColor() {
    if (state.appointmentDetail == null) return 'gray';

    switch (state.appointmentDetail!.status) {
      case 0:
        return 'orange'; // Chờ xác nhận
      case 1:
        return 'blue'; // Đã xác nhận
      case 2:
        return 'purple'; // Đang thực hiện
      case 3:
        return 'green'; // Hoàn thành
      case 4:
        return 'red'; // Đã hủy
      default:
        return 'gray';
    }
  }

  // Helper method to check if appointment can be cancelled
  bool canBeCancelled() {
    if (state.appointmentDetail == null) return false;

    return state.appointmentDetail!.status == AppointmentStatus.scheduled.value;
  }

  // Helper method to get total items count
  int getTotalItemsCount() {
    if (state.appointmentDetail == null) return 0;

    return state.appointmentDetail!.appointmentItems.length;
  }

  // Helper method to get total actual quantity
  int getTotalActualQuantity() {
    if (state.appointmentDetail == null) return 0;

    return state.appointmentDetail!.appointmentItems.fold<int>(
      0,
      (sum, item) => sum + item.actualQuantity,
    );
  }

  // Helper method to get total missing quantity
  int getTotalMissingQuantity() {
    if (state.appointmentDetail == null) return 0;

    return state.appointmentDetail!.appointmentItems.fold<int>(
      0,
      (sum, item) => sum + item.missingQuantity,
    );
  }

  // Helper method to check if appointment has missing items
  bool hasMissingItems() {
    return getTotalMissingQuantity() > 0;
  }

  // Helper method to get items by category
  Map<String, List<AppointmentItem>> getItemsByCategory() {
    if (state.appointmentDetail == null) return {};

    final Map<String, List<AppointmentItem>> categorizedItems = {};

    for (final item in state.appointmentDetail!.appointmentItems) {
      if (!categorizedItems.containsKey(item.categoryName)) {
        categorizedItems[item.categoryName] = [];
      }
      categorizedItems[item.categoryName]!.add(item);
    }

    return categorizedItems;
  }
}
