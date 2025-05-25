import 'package:flutter/material.dart';
import '../widgets/status_widget.dart';
import '../widgets/request_info_widget.dart';
import '../widgets/delivery_info_widget.dart';

class RequestDetailScreen extends StatelessWidget {
  final String title;
  final String type;
  final String status;
  final String location;
  final String date;

  const RequestDetailScreen({
    super.key,
    required this.title,
    required this.type,
    required this.status,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Chi tiết yêu cầu', style: theme.textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusWidget(status: status),
            const SizedBox(height: 20),
            RequestInfoWidget(
              title: title,
              type: type,
              location: location,
              date: date,
            ),
            if (type == 'GỬI ĐỒ CŨ') ...[
              const SizedBox(height: 20),
              const DeliveryInfoWidget(),
            ],
          ],
        ),
      ),
    );
  }
}
