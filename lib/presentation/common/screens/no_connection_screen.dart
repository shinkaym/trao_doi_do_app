import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/services/connectivity_service.dart';
import 'package:trao_doi_do_app/presentation/providers/connectivity_notifier.dart';

class NoConnectionScreen extends HookConsumerWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

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
                    // No connection illustration
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer.withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(80),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 80,
                            color: context.colorScheme.error.withOpacity(0.7),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: context.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Không có kết nối mạng',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Vui lòng kiểm tra kết nối internet và thử lại',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Connection details
                    _buildConnectionDetails(context, connectivityState),

                    const SizedBox(height: 32),

                    // Troubleshooting tips
                    _buildTroubleshootingTips(context),
                  ],
                ),
              ),

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed:
                      connectivityState.isLoading
                          ? null
                          : () => _handleRetry(context, ref),
                  icon:
                      connectivityState.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.refresh),
                  label: Text(
                    connectivityState.isLoading
                        ? 'Đang kiểm tra...'
                        : 'Thử lại',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionDetails(
    BuildContext context,
    ConnectivityState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Chi tiết kết nối',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildConnectionDetailRow(
            context,
            'Trạng thái',
            _getStatusText(state.status),
            _getStatusColor(context, state.status),
          ),

          if (state.connectionType.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildConnectionDetailRow(
              context,
              'Loại kết nối',
              state.connectionType,
              context.colorScheme.onSurfaceVariant,
            ),
          ],

          const SizedBox(height: 8),
          _buildConnectionDetailRow(
            context,
            'Cập nhật lần cuối',
            _formatLastUpdate(state.lastUpdated),
            context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionDetailRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingTips(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: context.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Gợi ý khắc phục',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTipItem(context, 'Kiểm tra kết nối WiFi hoặc dữ liệu di động'),
          _buildTipItem(context, 'Thử bật/tắt chế độ máy bay'),
          _buildTipItem(context, 'Khởi động lại router WiFi'),
          _buildTipItem(context, 'Liên hệ nhà cung cấp dịch vụ mạng'),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return 'Đã kết nối';
      case ConnectivityStatus.disconnected:
        return 'Không có kết nối';
      case ConnectivityStatus.limitedConnection:
        return 'Kết nối hạn chế';
      case ConnectivityStatus.unknown:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(BuildContext context, ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return Colors.green;
      case ConnectivityStatus.disconnected:
        return context.colorScheme.error;
      case ConnectivityStatus.limitedConnection:
        return Colors.orange;
      case ConnectivityStatus.unknown:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  String _formatLastUpdate(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa có';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else {
      return '${difference.inHours} giờ trước';
    }
  }

  void _handleRetry(BuildContext context, WidgetRef ref) async {
    final connectivityNotifier = ref.read(connectivityProvider.notifier);
    await connectivityNotifier.checkConnection();
  }
}
