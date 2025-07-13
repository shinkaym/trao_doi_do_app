import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/widgets/appointment_detail_dialog.dart';

class FcmNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void handleNotificationNavigation(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final targetType = data['targetType']?.toString().toLowerCase();
    final targetId = data['targetID']?.toString();
    final notificationId = data['ID']?.toString();

    if (targetType == null || targetId == null) {
      // Navigate to notifications list if no specific target
      context.push(RouteConstants.notifications);
      return;
    }

    switch (targetType) {
      case 'interest':
        context.pushNamed(
          RouteNames.interestChat,
          pathParameters: {'interestId': targetId},
        );
        break;

      case 'post':
        context.pushNamed(
          RouteNames.postDetailById,
          pathParameters: {'postId': targetId},
        );
        break;

      case 'appointment':
        _showAppointmentDetail(context, int.tryParse(targetId));
        break;

      default:
        context.push(RouteConstants.notifications);
        break;
    }

    // Mark notification as read if notification ID is available
    if (notificationId != null) {
      _markNotificationAsRead(context, int.tryParse(notificationId));
    }
  }

  static void _showAppointmentDetail(BuildContext context, int? appointmentId) {
    if (appointmentId == null) {
      context.push(RouteConstants.appointments);
      return;
    }

    try {
      final ref = ProviderScope.containerOf(context);
      final appointmentDetailNotifier = ref.read(
        appointmentDetailProvider(appointmentId).notifier,
      );

      // Load appointment detail
      appointmentDetailNotifier.loadAppointmentDetail(appointmentId);

      // Hiển thị dialog
      showDialog(
        context: context,
        builder:
            (context) => Consumer(
              builder: (context, ref, child) {
                final appointmentState = ref.watch(
                  appointmentDetailProvider(appointmentId),
                );

                if (appointmentState.isLoading) {
                  return Dialog(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Đang tải thông tin cuộc hẹn...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (appointmentState.failure != null) {
                  return AlertDialog(
                    title: const Text('Lỗi'),
                    content: Text(appointmentState.failure!.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Đóng'),
                      ),
                    ],
                  );
                }

                if (appointmentState.appointmentDetail != null) {
                  return AppointmentDetailDialog(
                    appointment: appointmentState.appointmentDetail!,
                    isTablet: MediaQuery.of(context).size.width >= 600,
                    theme: Theme.of(context),
                    colorScheme: Theme.of(context).colorScheme,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
      );
    } catch (e) {
      context.push(RouteConstants.appointments);
    }
  }

  static void _markNotificationAsRead(
    BuildContext context,
    int? notificationId,
  ) {
    if (notificationId == null) return;

    try {
      final container = ProviderScope.containerOf(context);
      container.read(notificationProvider.notifier).markAsRead(notificationId);
    } catch (e) {}
  }

  static void navigateToNotifications() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push(RouteConstants.notifications);
    }
  }

  static void navigateToPost(String postId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.pushNamed(
        RouteNames.postDetailById,
        pathParameters: {'postId': postId},
      );
    }
  }

  static void navigateToInterest(String interestId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.pushNamed(
        RouteNames.interestChat,
        pathParameters: {'interestId': interestId},
      );
    }
  }

  static void navigateToAppointments() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push(RouteConstants.appointments);
    }
  }
}
