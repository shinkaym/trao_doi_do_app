import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointments_usecase.dart';

class AppointmentsListState {
  final bool isLoading;
  final List<Appointment> appointments;
  final int currentPage;
  final int totalPage;
  final AppointmentQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;

  AppointmentsListState({
    this.isLoading = false,
    this.appointments = const [],
    this.currentPage = 1,
    this.totalPage = 1,
    this.query = const AppointmentQuery(),
    this.failure,
    this.hasMoreData = true,
    this.isLoadingPage = false,
  });

  AppointmentsListState copyWith({
    bool? isLoading,
    List<Appointment>? appointments,
    int? currentPage,
    int? totalPage,
    AppointmentQuery? query,
    Failure? failure,
    bool? hasMoreData,
    bool? isLoadingPage,
  }) {
    return AppointmentsListState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      query: query ?? this.query,
      failure: failure,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }
}

class AppointmentsListNotifier extends StateNotifier<AppointmentsListState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  int? _currentRequestId;
  int _nextRequestId = 1;

  AppointmentsListNotifier(this._getAppointmentsUseCase)
    : super(AppointmentsListState());

  Future<void> loadAppointments({
    AppointmentQuery? newQuery,
    bool refresh = false,
  }) async {
    if (state.isLoading || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.appointments.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
      );
    }

    final result = await _getAppointmentsUseCase(query);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            isLoadingPage: false,
            failure: failure,
          ),
      (appointmentsResult) {
        List<Appointment> newAppointments;

        if (isFirstLoad) {
          newAppointments = appointmentsResult.appointments;
        } else {
          newAppointments = state.appointments;
        }

        final actualTotalPage = appointmentsResult.totalPage;
        final actualCurrentPage = actualTotalPage > 0 ? state.query.page : 1;
        final actualHasMoreData =
            actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

        state = state.copyWith(
          isLoading: false,
          isLoadingPage: false,
          appointments: newAppointments,
          currentPage: actualCurrentPage,
          totalPage: actualTotalPage,
          hasMoreData: actualHasMoreData,
        );
      },
    );
  }

  // Chuyển đến trang cụ thể
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;

    // Tạo requestId mới cho lần gọi này
    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    // Hiển thị loading state khi chuyển trang
    state = state.copyWith(
      currentPage: page,
      isLoadingPage: true, // Bật loading để hiển thị skeleton
    );

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getAppointmentsUseCase(newQuery);

      // Kiểm tra xem request này còn là request mới nhất không
      if (_currentRequestId != requestId) {
        // Nếu có request mới hơn, bỏ qua kết quả này
        return;
      }

      result.fold(
        (failure) {
          // Chỉ cập nhật failure, không rollback currentPage
          state = state.copyWith(failure: failure, isLoadingPage: false);
        },
        (appointmentsResult) {
          final actualTotalPage = appointmentsResult.totalPage;
          final actualCurrentPage = actualTotalPage > 0 ? page : 1;
          final actualHasMoreData =
              actualTotalPage > 0 && actualCurrentPage < actualTotalPage;

          state = state.copyWith(
            appointments: appointmentsResult.appointments,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
            isLoadingPage: false,
          );
        },
      );
    } catch (e) {
      // Kiểm tra xem request này còn là request mới nhất không
      if (_currentRequestId != requestId) {
        return;
      }

      // Chỉ cập nhật trạng thái lỗi, không rollback currentPage
      state = state.copyWith(isLoadingPage: false);
    }
  }

  // Chuyển đến trang trước
  Future<void> goToPreviousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  // Chuyển đến trang tiếp theo
  Future<void> goToNextPage() async {
    if (state.currentPage < state.totalPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  // Chuyển đến trang đầu
  Future<void> goToFirstPage() async {
    await goToPage(1);
  }

  // Chuyển đến trang cuối
  Future<void> goToLastPage() async {
    await goToPage(state.totalPage);
  }

  void refresh() {
    loadAppointments(refresh: true);
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }

  void reset() {
    state = AppointmentsListState();
  }
}
