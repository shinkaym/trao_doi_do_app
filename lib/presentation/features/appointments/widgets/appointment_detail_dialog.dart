import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/appointment.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class AppointmentDetailDialog extends StatelessWidget {
  final Appointment appointment;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const AppointmentDetailDialog({
    super.key,
    required this.appointment,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final appointmentStatus = AppointmentStatus.fromValue(appointment.status);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReceiptHeader(context, appointmentStatus),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildReceiptDetails(),
                    _buildDashedDivider(),
                    _buildItemsList(),
                    _buildDashedDivider(),
                    _buildReceiptFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(BuildContext context, AppointmentStatus status) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: isTablet ? 20 : 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Store/App name
          Text(
            'TRAO ĐỔI ĐỒ',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          
          // Receipt title
          Text(
            'HÓA ĐƠN CUỘC HẸN',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: isTablet ? 16 : 14,
                  color: Colors.white,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetails() {
    DateTime startDateTime = DateTime.parse(appointment.startTime);
    DateTime endDateTime = DateTime.parse(appointment.endTime);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 16 : 12,
      ),
      child: Column(
        children: [
          _buildReceiptRow(
            'Mã cuộc hẹn:',
            '#${appointment.id?.toString().padLeft(6, '0') ?? 'N/A'}',
            isHeader: true,
          ),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Ngày bắt đầu:',
            TimeUtils.formatAbsolute(startDateTime).split(' ')[0],
          ),
          const SizedBox(height: 8),
          _buildReceiptRow(
            'Giờ bắt đầu:',
            TimeUtils.formatAbsolute(startDateTime).split(' ')[1],
          ),
          const SizedBox(height: 8),
          _buildReceiptRow(
            'Giờ kết thúc:',
            TimeUtils.formatAbsolute(endDateTime).split(' ')[1],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 16 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items header
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'MÓN ĐỒ',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'SL THỰC',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'THIẾU',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Items list
          if (appointment.appointmentItems.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 20),
                child: Text(
                  'Không có món đồ nào',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Column(
              children: appointment.appointmentItems
                  .asMap()
                  .entries
                  .map((entry) => _buildReceiptItem(entry.value, entry.key))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptItem(AppointmentItem item, int index) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.categoryName,
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 9,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${item.actualQuantity}',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${item.missingQuantity}',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: item.missingQuantity > 0 ? Colors.red[600] : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (index < appointment.appointmentItems.length - 1)
          const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReceiptFooter() {
    final totalItems = appointment.appointmentItems.length;
    final totalActual = appointment.appointmentItems
        .fold(0, (sum, item) => sum + item.actualQuantity);
    final totalMissing = appointment.appointmentItems
        .fold(0, (sum, item) => sum + item.missingQuantity);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        children: [
          _buildReceiptRow(
            'Tổng số loại món đồ:',
            '$totalItems',
            isTotal: true,
          ),
          const SizedBox(height: 8),
          _buildReceiptRow(
            'Tổng số lượng thực tế:',
            '$totalActual',
            isTotal: true,
          ),
          const SizedBox(height: 8),
          _buildReceiptRow(
            'Tổng số lượng thiếu:',
            '$totalMissing',
            isTotal: true,
            valueColor: totalMissing > 0 ? Colors.red[600] : null,
          ),
          const SizedBox(height: 20),
          
          // Thank you message
          Text(
            'CẢM ƠN BẠN ĐÃ SỬ DỤNG DỊCH VỤ!',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            TimeUtils.formatAbsolute(DateTime.now()),
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isHeader = false,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? (isHeader ? 14 : 12) : (isHeader ? 12 : 10),
            fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.w500,
            color: isHeader ? Colors.black87 : Colors.grey[700],
            letterSpacing: isHeader ? 0.5 : 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? (isHeader ? 14 : 12) : (isHeader ? 12 : 10),
            fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isHeader ? Colors.black87 : Colors.black87),
            letterSpacing: isHeader ? 0.5 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: DashedLinePainter(
          color: Colors.grey[400]!,
          strokeWidth: 1,
          dashWidth: 4,
          dashSpace: 4,
        ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}