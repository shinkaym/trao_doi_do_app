import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/filter_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/filter_indicator.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/request_item_card.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;
  int _page = 0;

  String? selectedType;
  String? selectedStatus;

  final List<String> typeOptions = [
    'NHẬN ĐỒ THẤT LẠC',
    'GỬI ĐỒ CŨ',
    'NHẬN ĐỒ CŨ',
  ];

  final List<String> statusOptions = ['Đang xử lý', 'Đã duyệt', 'Từ chối'];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMore();
      }
    });
  }

  void _loadMore() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));
    final newData = List.generate(
      5,
      (i) => {
        'type':
            i % 3 == 0
                ? 'NHẬN ĐỒ THẤT LẠC'
                : i % 3 == 1
                ? 'GỬI ĐỒ CŨ'
                : 'NHẬN ĐỒ CŨ',
        'status':
            i % 3 == 0
                ? 'Đang xử lý'
                : i % 3 == 1
                ? 'Đã duyệt'
                : 'Từ chối',
        'title': i % 2 == 0 ? 'Ví tiền' : 'Chìa khóa',
        'location': i % 2 == 0 ? 'Khu nhà F, lầu 5, phòng F5.12' : 'Căn tin',
        'date': '15/03/2024',
      },
    );

    setState(() {
      _requests.addAll(newData);
      _page++;
      _isLoading = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            typeOptions: typeOptions,
            statusOptions: statusOptions,
            selectedType: selectedType,
            selectedStatus: selectedStatus,
            onTypeChanged: (value) => setState(() => selectedType = value),
            onStatusChanged: (value) => setState(() => selectedStatus = value),
          ),
    );
  }

  void _onRemoveTypeFilter() {
    setState(() => selectedType = null);
  }

  void _onRemoveStatusFilter() {
    setState(() => selectedStatus = null);
  }

  void _onRequestTap(Map<String, dynamic> request) {
    context.push(
      '/request-detail'
      '?title=${Uri.encodeComponent(request['title'])}'
      '&type=${Uri.encodeComponent(request['type'])}'
      '&status=${Uri.encodeComponent(request['status'])}'
      '&location=${Uri.encodeComponent(request['location'])}'
      '&date=${Uri.encodeComponent(request['date'])}',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Yêu cầu đã gửi', style: theme.textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (selectedType != null || selectedStatus != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ext.accentLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterIndicator(
              selectedType: selectedType,
              selectedStatus: selectedStatus,
              onRemoveType: _onRemoveTypeFilter,
              onRemoveStatus: _onRemoveStatusFilter,
            );
          } else if (index == _requests.length + 1) {
            return _isLoading
                ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                : const SizedBox();
          }

          final req = _requests[index - 1];

          if ((selectedType != null && req['type'] != selectedType) ||
              (selectedStatus != null && req['status'] != selectedStatus)) {
            return const SizedBox.shrink();
          }

          return RequestItemCard(request: req, onTap: () => _onRequestTap(req));
        },
      ),
    );
  }
}
