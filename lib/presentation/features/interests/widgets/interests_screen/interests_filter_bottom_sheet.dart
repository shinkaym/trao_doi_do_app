import 'package:flutter/material.dart';

class InterestsFilterBottomSheet extends StatefulWidget {
  final String selectedSort;
  final Function(String) onApplySort;
  final VoidCallback onResetFilters;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const InterestsFilterBottomSheet({
    super.key,
    required this.selectedSort,
    required this.onApplySort,
    required this.onResetFilters,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<InterestsFilterBottomSheet> createState() =>
      _InterestsFilterBottomSheetState();
}

class _InterestsFilterBottomSheetState extends State<InterestsFilterBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Temporary state for filters
  late String _tempSelectedSort;

  @override
  void initState() {
    super.initState();

    // Initialize temporary state with current values
    _tempSelectedSort = widget.selectedSort;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _applyFilters() {
    widget.onApplySort(_tempSelectedSort);
    _closeSheet();
  }

  void _resetFilters() {
    setState(() {
      _tempSelectedSort = 'DESC';
    });
  }

  void _resetAndApply() {
    _resetFilters();
    widget.onResetFilters();
    _closeSheet();
  }

  bool get _hasChanges {
    return _tempSelectedSort != widget.selectedSort;
  }

  bool get _hasActiveFilters {
    return _tempSelectedSort != 'DESC';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Bottom Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 400),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: mediaQuery.size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.colorScheme.shadow.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: EdgeInsets.only(top: widget.isTablet ? 16 : 12),
                        width: widget.isTablet ? 48 : 40,
                        height: widget.isTablet ? 5 : 4,
                        decoration: BoxDecoration(
                          color: widget.colorScheme.onSurfaceVariant
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Header
                      _buildHeader(),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sort Filter Section
                              _buildFilterSection(
                                title: 'Sắp xếp theo',
                                icon: Icons.sort_outlined,
                                iconColor: Colors.orange.shade600,
                                iconBackgroundColor: Colors.orange.shade100,
                                child: _buildSortFilters(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: widget.colorScheme.primary.withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(widget.isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: widget.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: widget.colorScheme.primary,
              size: widget.isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: widget.isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bộ lọc quan tâm',
                  style: widget.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tùy chỉnh sắp xếp bài đăng quan tâm',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 12 : 10,
                vertical: widget.isTablet ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: widget.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: widget.isTablet ? 8 : 6,
                    color: widget.colorScheme.primary,
                  ),
                  SizedBox(width: widget.isTablet ? 6 : 4),
                  Text(
                    'Đã thay đổi',
                    style: TextStyle(
                      color: widget.colorScheme.onPrimaryContainer,
                      fontSize: widget.isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: widget.isTablet ? 12 : 8),
          ],
          IconButton(
            onPressed: _closeSheet,
            icon: Icon(
              Icons.close_rounded,
              color: widget.colorScheme.onSurfaceVariant,
              size: widget.isTablet ? 22 : 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: widget.colorScheme.surface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(widget.isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: widget.isTablet ? 20 : 18,
                  color: iconColor,
                ),
              ),
              SizedBox(width: widget.isTablet ? 12 : 10),
              Text(
                title,
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: widget.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSortFilters() {
    final sortOptions = [
      {'value': 'DESC', 'label': 'Mới nhất', 'icon': Icons.access_time_rounded},
      {'value': 'ASC', 'label': 'Cũ nhất', 'icon': Icons.history_rounded},
    ];

    return Wrap(
      spacing: widget.isTablet ? 12 : 10,
      runSpacing: widget.isTablet ? 12 : 10,
      children:
          sortOptions
              .map(
                (sort) => _buildFilterChip(
                  label: sort['label'] as String,
                  icon: sort['icon'] as IconData,
                  isSelected: _tempSelectedSort == sort['value'],
                  onSelected: () {
                    setState(() {
                      _tempSelectedSort = sort['value'] as String;
                    });
                  },
                ),
              )
              .toList(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Material(
      elevation: isSelected ? 4 : 0,
      borderRadius: BorderRadius.circular(24),
      shadowColor: widget.colorScheme.primary.withOpacity(0.3),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 18 : 16,
            vertical: widget.isTablet ? 14 : 12,
          ),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        widget.colorScheme.primary,
                        widget.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color:
                isSelected
                    ? null
                    : widget.colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isSelected
                      ? widget.colorScheme.primary.withOpacity(0.3)
                      : widget.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: widget.isTablet ? 20 : 18,
                color:
                    isSelected
                        ? Colors.white
                        : widget.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : widget.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: widget.isTablet ? 15 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        widget.isTablet ? 24 : 20,
        widget.isTablet ? 16 : 12,
        widget.isTablet ? 24 : 20,
        widget.isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: widget.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Reset button (if has active filters)
          if (_hasActiveFilters) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetAndApply,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: widget.isTablet ? 20 : 18,
                ),
                label: Text(
                  'Đặt lại bộ lọc',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.isTablet ? 15 : 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.isTablet ? 16 : 14,
                    horizontal: widget.isTablet ? 24 : 20,
                  ),
                  side: BorderSide(
                    color: widget.colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: widget.colorScheme.surface,
                  foregroundColor: widget.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: widget.isTablet ? 16 : 12),
          ],

          // Main action buttons
          Row(
            children: [
              // Apply Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasChanges ? _applyFilters : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isTablet ? 16 : 14,
                      horizontal: widget.isTablet ? 24 : 20,
                    ),
                    backgroundColor:
                        _hasChanges
                            ? widget.colorScheme.primary
                            : widget.colorScheme.surfaceVariant,
                    foregroundColor:
                        _hasChanges
                            ? Colors.white
                            : widget.colorScheme.onSurfaceVariant,
                    elevation: _hasChanges ? 3 : 0,
                    shadowColor: widget.colorScheme.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: widget.isTablet ? 20 : 18,
                      ),
                      SizedBox(width: widget.isTablet ? 8 : 6),
                      Text(
                        'Áp dụng',
                        style: widget.theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: widget.isTablet ? 16 : 14,
                          color:
                              _hasChanges
                                  ? Colors.white
                                  : widget.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
