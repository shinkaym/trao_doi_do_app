// post_screen.dart
import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/filter_sheet.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_single.dart';
import 'package:trao_doi_do_app/presentation/widgets/pagination_control.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_bar.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Tất cả';
  String _selectedSort = 'Mới nhất';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Map<String, String>> allItems = List.generate(
    50,
    (index) => {
      'name': "Đồ vật ${index + 1}",
      'description': "Mô tả chi tiết cho đồ vật ${index + 1}",
      'sender': "Người dùng ${index + 1}",
      'time': '26/05/2025',
      'quantity': "${index % 5 + 1}",
      'imageUrl': 'https://via.placeholder.com/400',
      'address': 'Hà Nội',
      'status': index % 2 == 0 ? 'Đã tìm thấy' : 'Chưa tìm thấy',
    },
  );

  List<Map<String, String>> get _filteredItems {
    List<Map<String, String>> filtered = allItems;

    if (_searchController.text.isNotEmpty) {
      filtered =
          filtered.where((item) => item['name']!.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              )).toList();
    }

    if (_selectedStatus != 'Tất cả') {
      filtered =
          filtered.where((item) => item['status'] == _selectedStatus).toList();
    }

    if (_selectedSort == 'Mới nhất') {
      filtered = filtered.reversed.toList();
    }

    return filtered;
  }

  int get _totalPages => (_filteredItems.length / _itemsPerPage).ceil();

  List<Map<String, String>> get _pagedItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _filteredItems.sublist(
      start,
      end > _filteredItems.length ? _filteredItems.length : end,
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(
        initialStatus: _selectedStatus,
        initialSort: _selectedSort,
        onApply: (status, sort) {
          setState(() {
            _selectedStatus = status;
            _selectedSort = sort;
            _currentPage = 1;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho đồ cũ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
            color: ext.secondary,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: () => setState(() => _currentPage = 1),
          ),
          Expanded(
            child: _pagedItems.isEmpty
                ? const Center(child: Text('Không có bài đăng nào'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: _pagedItems.length + (_totalPages > 1 ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (_totalPages > 1 && index == _pagedItems.length) {
                        return PaginationControls(
                          totalPages: _totalPages,
                          currentPage: _currentPage,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                          },
                        );
                      }
                      final item = _pagedItems[index];
                      return ItemSingle(
                        name: item['name']!,
                        description: item['description']!,
                        sender: item['sender']!,
                        time: item['time']!,
                        quantity: item['quantity']!,
                        imageUrl: item['imageUrl']!,
                        address: item['address']!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
