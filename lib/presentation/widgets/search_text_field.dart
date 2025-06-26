import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onToggle;
  final VoidCallback onClear;
  final bool isTablet;
  final ColorScheme colorScheme;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onToggle,
    required this.onClear,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes để rebuild widget
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 16 : 12,
        vertical: widget.isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: widget.colorScheme.primary,
            size: widget.isTablet ? 20 : 18,
          ),
          SizedBox(width: widget.isTablet ? 8 : 6),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa tìm kiếm...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: widget.colorScheme.onSurfaceVariant,
                  fontSize: widget.isTablet ? 16 : 14,
                ),
              ),
              style: TextStyle(
                color: widget.colorScheme.onSurface,
                fontSize: widget.isTablet ? 16 : 14,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty) ...[
            SizedBox(width: widget.isTablet ? 8 : 4),
            InkWell(
              onTap: () {
                widget.controller.clear();
                widget.onClear();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.clear,
                  color: widget.colorScheme.onSurfaceVariant,
                  size: widget.isTablet ? 16 : 14,
                ),
              ),
            ),
          ],
          SizedBox(width: widget.isTablet ? 8 : 4),
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.keyboard_arrow_up,
                color: widget.colorScheme.onSurfaceVariant,
                size: widget.isTablet ? 20 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}