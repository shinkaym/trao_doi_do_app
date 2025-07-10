import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointments_usecase.dart';

class AppointmentsListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Appointment> appointments;
  final int currentPage;
  final int totalPage;
  final AppointmentQuery query;
  final Failure? failure;
  final bool hasMoreData;
  final bool isLoadingPage;

  AppointmentsListState({
    this.isLoading = false,
    this.isLoadingMore = false,
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
    bool? isLoadingMore,
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
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
    bool isLoadMore = false,
    bool isGoToPage = false,
  }) async {
    // Ngăn chặn multiple calls cùng lúc
    if (state.isLoading || state.isLoadingMore || state.isLoadingPage) return;

    final query = newQuery ?? state.query;
    final isFirstLoad = refresh || state.appointments.isEmpty;

    if (isFirstLoad) {
      state = state.copyWith(
        isLoading: true,
        failure: null,
        query: query.copyWith(page: 1),
        appointments: [],
      );
    } else if (isLoadMore) {
      if (!state.hasMoreData || state.currentPage >= state.totalPage) return;

      state = state.copyWith(
        isLoadingMore: true,
        failure: null,
        query: query.copyWith(page: state.currentPage + 1),
      );
    } else if (isGoToPage) {
      state = state.copyWith(isLoadingPage: true, failure: null, query: query);
    }

    try {
      final result = await _getAppointmentsUseCase(state.query);

      result.fold(
        (failure) =>
            state = state.copyWith(
              isLoading: false,
              isLoadingMore: false,
              isLoadingPage: false,
              failure: failure,
            ),
        (appointmentsResult) {
          List<Appointment> newAppointments;

          if (isFirstLoad) {
            newAppointments = appointmentsResult.appointments;
          } else if (isLoadMore) {
            newAppointments = [
              ...state.appointments,
              ...appointmentsResult.appointments,
            ];
          } else if (isGoToPage) {
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
            isLoadingMore: false,
            isLoadingPage: false,
            appointments: newAppointments,
            currentPage: actualCurrentPage,
            totalPage: actualTotalPage,
            hasMoreData: actualHasMoreData,
            failure: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        isLoadingPage: false,
        failure: ServerFailure('Đã xảy ra lỗi không mong muốn'),
      );
    }
  }

  // Pagination methods
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPage || page == state.currentPage) return;

    // Tạo requestId mới
    final requestId = _nextRequestId++;
    _currentRequestId = requestId;

    // Cập nhật UI ngay lập tức
    state = state.copyWith(currentPage: page, isLoadingPage: false);

    final newQuery = state.query.copyWith(page: page);

    try {
      final result = await _getAppointmentsUseCase(newQuery);

      if (_currentRequestId != requestId) return;

      result.fold((failure) => state = state.copyWith(failure: failure), (
        data,
      ) {
        state = state.copyWith(
          appointments: data.appointments,
          currentPage: page,
          totalPage: data.totalPage,
          hasMoreData: page < data.totalPage,
        );
      });
    } catch (e) {
      if (_currentRequestId != requestId) return;
      state = state.copyWith(isLoadingPage: false);
    }
  }

  Future<void> goToPreviousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  Future<void> goToNextPage() async {
    if (state.currentPage < state.totalPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  // Filter and search methods
  void search(String? searchBy, String? searchValue) {
    final newQuery = state.query.copyWith(
      searchBy: searchBy,
      searchValue: searchValue,
      page: 1,
    );
    loadAppointments(newQuery: newQuery, refresh: true);
  }

  void loadMore() {
    loadAppointments(isLoadMore: true);
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

  Future<void> goToFirstPage() async {
    if (state.currentPage != 1) {
      await goToPage(1);
    }
  }

  Future<void> goToLastPage() async {
    if (state.currentPage != state.totalPage && state.totalPage > 0) {
      await goToPage(state.totalPage);
    }
  }
}
