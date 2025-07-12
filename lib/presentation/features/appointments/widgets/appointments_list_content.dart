import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/notifiers/appointments_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_card.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_detail_dialog.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_skeleton.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointments_empty_state.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointments_pagination.dart';

class AppointmentsListContent extends HookConsumerWidget {
  final AppointmentsListState appointmentsState;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final SortOrder selectedSort;
  final Function(Appointment) onRejectAppointment;
  final VoidCallback onRefresh;
  final VoidCallback onResetFilters;
  final ScrollController scrollController;

  const AppointmentsListContent({
    super.key,
    required this.appointmentsState,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.selectedSort,
    required this.onRejectAppointment,
    required this.onRefresh,
    required this.onResetFilters,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hiển thị skeleton khi đang loading lần đầu (không có dữ liệu)
    if (appointmentsState.isLoading && appointmentsState.appointments.isEmpty) {
      return _buildSkeletonContent();
    }

    // Hiển thị empty state khi không có dữ liệu và không loading
    if (appointmentsState.appointments.isEmpty &&
        !appointmentsState.isLoading) {
      return _buildEmptyState();
    }

    // Hiển thị danh sách appointments (có thể có skeleton cho pagination)
    return _buildAppointmentsList();
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(height: isTablet ? 16 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            child: AppointmentSkeletonList(
              isTablet: isTablet,
              colorScheme: colorScheme,
              itemCount: 10,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: AppointmentsEmptyState(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  selectedSort: selectedSort,
                  onResetFilters: onResetFilters,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Appointments List hoặc Skeleton khi loading pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver:
                appointmentsState.isLoadingPage || appointmentsState.isLoading
                    ? SliverToBoxAdapter(
                      child: AppointmentSkeletonList(
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                        itemCount: 10,
                      ),
                    )
                    : SliverList.separated(
                      itemCount: appointmentsState.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            appointmentsState.appointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          onReject: () => onRejectAppointment(appointment),
                          onTap:
                              () =>
                                  _showAppointmentDetail(context, appointment),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: isTablet ? 8 : 6);
                      },
                    ),
          ),

          // Pagination - luôn hiển thị khi có nhiều trang
          if (appointmentsState.totalPage > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: AppointmentsPagination(
                  state: appointmentsState,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 100 : 80)),
        ],
      ),
    );
  }

  void _showAppointmentDetail(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AppointmentDetailDialog(
            appointment: appointment,
            isTablet: isTablet,
            theme: theme,
            colorScheme: colorScheme,
          ),
    );
  }
}
