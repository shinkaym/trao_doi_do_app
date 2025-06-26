import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/providers/appointments_provider.dart';
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
    // Hiển thị skeleton khi đang loading lần đầu
    if (appointmentsState.isLoading && appointmentsState.appointments.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(height: isTablet ? 16 : 8),
            AppointmentSkeletonList(
              isTablet: isTablet,
              colorScheme: colorScheme,
              itemCount: 10,
            ),
            SizedBox(height: isTablet ? 24 : 16),
          ],
        ),
      );
    }

    // Hiển thị empty state - FIX: Sử dụng LayoutBuilder để lấy chiều cao available
    if (appointmentsState.appointments.isEmpty &&
        !appointmentsState.isLoading) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Cho phép pull to refresh
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight, // Đảm bảo chiều cao tối thiểu
                ),
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

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Top spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 16 : 8)),

          // Appointments List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
            sliver: SliverList.separated(
              itemCount: appointmentsState.appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointmentsState.appointments[index];
                return AppointmentCard(
                  appointment: appointment,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  onReject: () => onRejectAppointment(appointment),
                  onTap: () => _showAppointmentDetail(context, appointment),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: isTablet ? 8 : 6);
              },
            ),
          ),

          // Pagination - integrated in the scroll view
          if (appointmentsState.totalPage > 1 &&
              appointmentsState.appointments.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 6),
                child: AppointmentsPagination(
                  state: appointmentsState,
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  onPageChanged: (page) {
                    ref.read(appointmentsListProvider.notifier).goToPage(page);
                  },
                  onPreviousPage: () {
                    ref
                        .read(appointmentsListProvider.notifier)
                        .goToPreviousPage();
                  },
                  onNextPage: () {
                    ref.read(appointmentsListProvider.notifier).goToNextPage();
                  },
                  onFirstPage: () {
                    ref.read(appointmentsListProvider.notifier).goToFirstPage();
                  },
                  onLastPage: () {
                    ref.read(appointmentsListProvider.notifier).goToLastPage();
                  },
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
