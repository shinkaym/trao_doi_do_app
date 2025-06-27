import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class AppointmentCard extends HookConsumerWidget {
  final Appointment appointment;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentStatus = AppointmentStatus.fromValue(appointment.status);
    final isUpdating = ref.watch(appointmentUpdatingProvider(appointment.id));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(appointmentStatus),
              SizedBox(height: isTablet ? 20 : 16),
              _buildContentSections(),
              if (appointmentStatus == AppointmentStatus.scheduled &&
                  onReject != null)
                _buildActionSection(isUpdating),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppointmentStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: isTablet ? 16 : 14, color: status.color),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: status.color,
                ),
              ),
            ],
          ),
        ),
        Text(
          TimeUtils.formatTimeAgo(DateTime.parse(appointment.createdAt)),
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSections() {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTimeSection(),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          _buildItemsSection(),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    String startDateTime = TimeUtils.formatAbsolute(
      DateTime.parse(appointment.startTime),
    );
    String endDateTime = TimeUtils.formatAbsolute(
      DateTime.parse(appointment.endTime),
    );

    return Padding(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: isTablet ? 20 : 18,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: isTablet ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian hẹn',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 11,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bắt đầu',
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 9,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            startDateTime,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 6,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: isTablet ? 16 : 14,
                        color: theme.hintColor,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết thúc',
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 9,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            endDateTime,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    // Cấu hình số lượng item hiển thị tối đa
    const int maxVisibleItems = 3;
    final hasMoreItems = appointment.appointmentItems.length > maxVisibleItems;
    final visibleItems =
        hasMoreItems
            ? appointment.appointmentItems.take(maxVisibleItems).toList()
            : appointment.appointmentItems;
    final remainingCount =
        appointment.appointmentItems.length - maxVisibleItems;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: isTablet ? 20 : 18,
              color: colorScheme.secondary,
            ),
          ),
          SizedBox(width: isTablet ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Các món đồ',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 6,
                        vertical: isTablet ? 2 : 1,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${appointment.appointmentItems.length}',
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 9,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 8 : 6),
                if (appointment.appointmentItems.isEmpty)
                  Text(
                    'Không có món đồ nào',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else ...[
                  // Hiển thị các item (giới hạn số lượng)
                  ...visibleItems.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet ? 6 : 4,
                            height: isTablet ? 6 : 4,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isTablet ? 10 : 8),
                          Expanded(
                            child: Text(
                              '${item.itemName}',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6,
                              vertical: isTablet ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(
                                0.6,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x${item.actualQuantity}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hiển thị thông báo "và X món khác" nếu có nhiều hơn
                  if (hasMoreItems)
                    Padding(
                      padding: EdgeInsets.only(top: isTablet ? 4 : 2),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.more_horiz,
                              size: isTablet ? 16 : 14,
                              color: colorScheme.secondary,
                            ),
                            SizedBox(width: isTablet ? 6 : 4),
                            Text(
                              'và $remainingCount món khác',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(bool isUpdating) {
    return Column(
      children: [
        SizedBox(height: isTablet ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isUpdating ? null : onReject,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  backgroundColor: Colors.red.shade600,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUpdating) ...[
                      SizedBox(
                        width: isTablet ? 16 : 14,
                        height: isTablet ? 16 : 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        'Đang xử lý...',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.cancel_outlined,
                        size: isTablet ? 18 : 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        'Từ chối',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
