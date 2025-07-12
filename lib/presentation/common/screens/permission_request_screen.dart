import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/notifiers/permission_notifier.dart';

class PermissionRequestScreen extends HookConsumerWidget {
  const PermissionRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.security,
                        size: 60,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Cấp quyền truy cập',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Ứng dụng cần một số quyền để hoạt động tốt nhất',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Permission List
                    _buildPermissionList(context, permissionState),

                    if (permissionState.hasError) ...[
                      const SizedBox(height: 24),
                      _buildErrorMessage(context, permissionState.error!),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          permissionState.isLoading
                              ? null
                              : () => _handleRequestPermissions(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorScheme.primary,
                        foregroundColor: context.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          permissionState.isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Cấp quyền',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (permissionState.hasPermissionsPermanentlyDenied) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _handleOpenSettings(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colorScheme.primary,
                          side: BorderSide(color: context.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Mở cài đặt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextButton(
                    onPressed: () => _handleSkip(context, ref),
                    child: Text(
                      'Bỏ qua (không khuyến nghị)',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionList(BuildContext context, PermissionState state) {
    final permissions = [
      _PermissionItem(
        permission: Permission.camera,
        title: 'Camera',
        description: 'Để chụp ảnh sản phẩm khi đăng bài',
        icon: Icons.camera_alt,
        isGranted: state.isCameraGranted,
      ),
      _PermissionItem(
        permission: Permission.notification,
        title: 'Thông báo',
        description: 'Để nhận thông báo về tin nhắn và cập nhật',
        icon: Icons.notifications,
        isGranted: state.isNotificationGranted,
      ),
    ];

    return Column(
      children:
          permissions
              .map((item) => _buildPermissionItem(context, item))
              .toList(),
    );
  }

  Widget _buildPermissionItem(BuildContext context, _PermissionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              item.isGranted
                  ? context.colorScheme.primary.withOpacity(0.3)
                  : context.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  item.isGranted
                      ? context.colorScheme.primary
                      : context.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.isGranted ? Icons.check : item.icon,
              color:
                  item.isGranted
                      ? context.colorScheme.onPrimary
                      : context.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (item.isGranted)
            Icon(
              Icons.check_circle,
              color: context.colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRequestPermissions(BuildContext context, WidgetRef ref) async {
    final permissionNotifier = ref.read(permissionProvider.notifier);
    final success = await permissionNotifier.requestRequiredPermissions();

    if (success) {
      _navigateToNextScreen(context);
    }
  }

  void _handleOpenSettings(BuildContext context, WidgetRef ref) async {
    final permissionNotifier = ref.read(permissionProvider.notifier);
    await permissionNotifier.openAppSettings();
  }

  void _handleSkip(BuildContext context, WidgetRef ref) {
    ref.read(permissionRequestSkippedProvider.notifier).state = true;
    _navigateToNextScreen(context);
  }

  void _navigateToNextScreen(BuildContext context) {
    context.goNamed(RouteNames.home);
  }
}

class _PermissionItem {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;
  final bool isGranted;

  const _PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
  });
}
