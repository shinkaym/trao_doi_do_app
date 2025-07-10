import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/domain/usecases/params/appointment_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointments_list_content.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointments_filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointments_top_action_bar.dart';
import 'package:trao_doi_do_app/presentation/widgets/scroll_to_top_button.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class AppointmentsScreen extends HookConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsListProvider);

    final selectedSort = useState<SortOrder>(
      appointmentsState.query.sort != null &&
              appointmentsState.query.order != null
          ? SortOrder.values.firstWhere(
            (sort) =>
                sort.sort == appointmentsState.query.sort &&
                sort.order == appointmentsState.query.order,
            orElse: () => SortOrder.startTimeDesc,
          )
          : SortOrder.startTimeDesc,
    );

    final scrollController = useScrollController();
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    void loadAppointments({bool refresh = false}) {
      final query = AppointmentQuery(
        sort: selectedSort.value.sort,
        order: selectedSort.value.order,
        page: refresh ? 1 : appointmentsState.currentPage,
      );

      ref
          .read(appointmentsListProvider.notifier)
          .loadAppointments(newQuery: query, refresh: refresh);
    }

    void handleApplyFilters(SortOrder sort) {
      selectedSort.value = sort;
      loadAppointments(refresh: true);
    }

    void handleRefresh() {
      loadAppointments(refresh: true);
    }

    void handleRejectAppointment(Appointment appointment) async {
      final confirmed = await context.showConfirmDialog(
        title: 'Từ chối cuộc hẹn',
        content: 'Bạn có chắc chắn muốn từ chối cuộc hẹn này không?',
        confirmText: 'Từ chối',
        cancelText: 'Hủy',
        isDangerous: true,
      );

      if (confirmed == true) {
        // Show loading state
        final loadingAppointments =
            ref.read(appointmentProvider).updatingAppointments;
        if (loadingAppointments[appointment.id] == true) return;

        // Update appointment status to 4 (cancelled/rejected)
        await ref
            .read(appointmentProvider.notifier)
            .cancelAppointment(appointment.id);

        // Check the result after the operation
        final appointmentState = ref.read(appointmentProvider);
        if (appointmentState.successMessage != null) {
          context.showSuccessSnackBar('Đã từ chối cuộc hẹn!');
          // Clear the success message and refresh
          ref.read(appointmentProvider.notifier).clearSuccess();
          loadAppointments(refresh: true);
        } else if (appointmentState.failure != null) {
          ref.read(appointmentProvider.notifier).clearError();
        }
      }
    }

    void resetAll() {
      selectedSort.value = SortOrder.startTimeDesc;
      loadAppointments(refresh: true);
    }

    void showFilterBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => AppointmentsFilterBottomSheet(
              selectedSort: selectedSort.value,
              onApplyFilters: handleApplyFilters,
              onResetFilters: resetAll,
              isTablet: isTablet,
              theme: theme,
              colorScheme: colorScheme,
            ),
      );
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appointmentsState.appointments.isEmpty) {
          resetAll();
        }
      });
      return null;
    }, []);

    return SmartScaffold(
      appBarType: AppBarType.standard,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppointmentsTopActionBar(
                  onFilterPressed: showFilterBottomSheet,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  hasActiveFilters:
                      selectedSort.value != SortOrder.startTimeDesc,
                ),
                Expanded(
                  child: AppointmentsListContent(
                    appointmentsState: appointmentsState,
                    isTablet: isTablet,
                    theme: theme,
                    colorScheme: colorScheme,
                    selectedSort: selectedSort.value,
                    onRejectAppointment: handleRejectAppointment,
                    onRefresh: handleRefresh,
                    onResetFilters: resetAll,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
            ScrollToTopButton(
              scrollController: scrollController,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}
