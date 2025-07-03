import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar/app_bar_actions.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar/app_bar_leading.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar/app_bar_search_overlay.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_app_bar/app_bar_title.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Widget>? additionalActions;
  final PreferredSizeWidget? bottom;
  final bool showSearchButton;
  final Function(String)? onSearch;
  final String? searchHint;
  final TextEditingController? searchController;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotificationButton = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.additionalActions,
    this.bottom,
    this.showSearchButton = false,
    this.onSearch,
    this.searchHint = 'Tìm kiếm...',
    this.searchController,
  });

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize {
    final isTablet =
        WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .physicalSize
                .width /
            WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .devicePixelRatio >
        600;
    final toolbarHeight = isTablet ? 70.0 : 60.0;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}

class _CustomAppBarState extends ConsumerState<CustomAppBar>
    with TickerProviderStateMixin {
  bool _isSearchMode = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    _searchFocusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (_isSearchMode) {
        _searchAnimationController.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchFocusNode.unfocus();
        _hideOverlay();
        ref.read(searchSuggestionsProvider.notifier).clear();
      }
    });
  }

  void _performSearch(String query) {
    if (widget.onSearch != null) {
      widget.onSearch!(query);
    }
    ref.read(searchSuggestionsProvider.notifier).searchWithDebounce(query);
    if (query.trim().isNotEmpty && _searchFocusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = AppBarSearchOverlay.createOverlay(
      context: context,
      onPostTap: (post) {
        _hideOverlay();
        _navigateToPostDetail(context, post);
      },
      onViewAll: () {
        _hideOverlay();
        final searchState = ref.read(searchSuggestionsProvider);
        _navigateToPostsWithSearch(context, searchState.query);
      },
    );
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _navigateToPostDetail(BuildContext context, post) {
    context.pushNamed(
      RouteNames.postDetail,
      pathParameters: {'slug': post.slug.toString()},
    );
    _toggleSearch();
  }

  void _navigateToPostsWithSearch(BuildContext context, String searchQuery) {
    if (searchQuery.trim().isEmpty) return;
    context.pushNamed(
      RouteNames.posts,
      extra: {'search': searchQuery.trim(), 'autoFocus': false},
    );
    _toggleSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;
    final appBarBgColor =
        widget.backgroundColor ??
        (isDark ? const Color(0xFF1B1B1B) : Colors.white);
    final appBarFgColor =
        widget.foregroundColor ??
        (isDark ? Colors.white : const Color(0xFF1C1E21));
    final toolbarHeight = isTablet ? 70.0 : 60.0;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AppBar(
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        elevation: 0,
        toolbarHeight: toolbarHeight,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: appBarBgColor,
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        bottom:
            widget.bottom != null
                ? PreferredSize(
                  preferredSize: widget.bottom!.preferredSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appBarBgColor,
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isDark
                                  ? Colors.grey.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: widget.bottom!,
                  ),
                )
                : null,
        leading: AppBarLeading(
          isSearchMode: _isSearchMode,
          showBackButton: widget.showBackButton,
          onBackPressed: widget.onBackPressed,
          onToggleSearch: _toggleSearch,
          isTablet: isTablet,
          isDark: isDark,
          appBarBgColor: appBarBgColor,
          appBarFgColor: appBarFgColor,
        ),
        title: AppBarTitle(
          title: widget.title,
          isSearchMode: _isSearchMode,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          searchHint: widget.searchHint,
          onSearchChanged: (value) {
            setState(() {});
            _performSearch(value);
          },
          onSearchSubmitted: (value) {
            _performSearch(value);
            _navigateToPostsWithSearch(context, value);
          },
          onSearchClear: () {
            _searchController.clear();
            _hideOverlay();
            ref.read(searchSuggestionsProvider.notifier).clear();
            setState(() {});
          },
          searchAnimation: _searchAnimation,
          isTablet: isTablet,
          isDark: isDark,
          appBarBgColor: appBarBgColor,
          appBarFgColor: appBarFgColor,
        ),
        actions:
            _isSearchMode
                ? []
                : AppBarActions(
                  showSearchButton: widget.showSearchButton,
                  showNotificationButton: widget.showNotificationButton,
                  notificationCount: widget.notificationCount,
                  onNotificationTap: widget.onNotificationTap,
                  onToggleSearch: _toggleSearch,
                  additionalActions: widget.additionalActions,
                  isTablet: isTablet,
                  isDark: isDark,
                  foregroundColor: appBarFgColor,
                ).build(context),
        titleSpacing: 0,
      ),
    );
  }
}
