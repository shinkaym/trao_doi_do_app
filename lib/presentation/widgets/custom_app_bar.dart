import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_suggestions_overlay.dart';

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

  // Search related properties
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
  FocusNode _searchFocusNode = FocusNode();
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

    // Listen to focus changes
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
        // Clear search suggestions
        ref.read(searchSuggestionsProvider.notifier).clear();
      }
    });
  }

  void _performSearch(String query) {
    if (widget.onSearch != null) {
      widget.onSearch!(query);
    }

    // Trigger search suggestions
    ref.read(searchSuggestionsProvider.notifier).searchWithDebounce(query);

    if (query.trim().isNotEmpty && _searchFocusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: offset.dy + size.height,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Consumer(
                builder: (context, ref, child) {
                  final searchState = ref.watch(searchSuggestionsProvider);

                  if (searchState.query.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return SearchSuggestionsOverlay(
                    suggestions: searchState.suggestions,
                    isLoading: searchState.isLoading,
                    searchQuery: searchState.query,
                    onPostTap: (post) {
                      _hideOverlay();
                      _navigateToPostDetail(context, post);
                    },
                    onViewAll: () {
                      _hideOverlay();
                      _navigateToPostsWithSearch(context, searchState.query);
                    },
                  );
                },
              ),
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _navigateToPostDetail(BuildContext context, post) {
    context.pushNamed(
      'post-detail',
      pathParameters: {'slug': post.slug.toString()},
    );
    _toggleSearch();
  }

  void _navigateToPostsWithSearch(BuildContext context, String searchQuery) {
    if (searchQuery.trim().isEmpty) return;

    context.pushNamed(
      'posts',
      extra: {'search': searchQuery.trim(), 'autoFocus': false},
    );

    _toggleSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;

    // Facebook-inspired colors
    final appBarBgColor =
        widget.backgroundColor ??
        (isDark ? const Color(0xFF1B1B1B) : Colors.white);
    final appBarFgColor =
        widget.foregroundColor ??
        (isDark ? Colors.white : const Color(0xFF1C1E21));
    final toolbarHeight = isTablet ? 70.0 : 60.0;

    // Tạo SystemUiOverlayStyle một lần duy nhất
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
        leading: _buildLeading(
          context,
          isTablet,
          isDark,
          appBarBgColor,
          appBarFgColor,
        ),
        title: _buildTitle(
          context,
          isTablet,
          isDark,
          appBarBgColor,
          appBarFgColor,
        ),
        actions:
            _isSearchMode
                ? []
                : _buildActions(context, appBarFgColor, isTablet, isDark),
        titleSpacing: 0,
      ),
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    bool isTablet,
    bool isDark,
    Color appBarBgColor,
    Color appBarFgColor,
  ) {
    if (_isSearchMode) {
      return Container(
        margin: EdgeInsets.only(left: isTablet ? 12 : 8),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appBarFgColor,
              size: isTablet ? 20 : 18,
            ),
          ),
          onPressed: _toggleSearch,
        ),
      );
    }

    if (widget.showBackButton) {
      return Container(
        margin: EdgeInsets.only(left: isTablet ? 12 : 8),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appBarFgColor,
              size: isTablet ? 20 : 18,
            ),
          ),
          onPressed:
              widget.onBackPressed ??
              () {
                if (context.canPop) {
                  context.pop();
                } else {
                  context.goNamed(RouteNames.home);
                }
              },
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(left: isTablet ? 16 : 12),
      child: _buildLogo(context, isTablet),
    );
  }

  Widget? _buildTitle(
    BuildContext context,
    bool isTablet,
    bool isDark,
    Color appBarBgColor,
    Color appBarFgColor,
  ) {
    if (_isSearchMode) {
      return AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.only(
              right: isTablet ? 16 : 12,
              top: isTablet ? 12 : 8,
              bottom: isTablet ? 12 : 8,
            ),
            child: Row(
              children: [
                // Search input field
                Expanded(
                  child: Container(
                    height: isTablet ? 46 : 40,
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        color: appBarFgColor,
                        fontSize: isTablet ? 16 : 14,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        hintStyle: TextStyle(
                          color: appBarFgColor.withOpacity(0.6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 14 : 12,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: appBarFgColor.withOpacity(0.6),
                                    size: isTablet ? 22 : 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _hideOverlay();
                                    ref
                                        .read(
                                          searchSuggestionsProvider.notifier,
                                        )
                                        .clear();
                                    setState(() {});
                                  },
                                )
                                : Icon(
                                  Icons.search_rounded,
                                  color: appBarFgColor.withOpacity(0.6),
                                  size: isTablet ? 22 : 20,
                                ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        _performSearch(value);
                      },
                      onSubmitted: (value) {
                        _performSearch(value);
                        _navigateToPostsWithSearch(context, value);
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Hiển thị title động dựa trên trạng thái đăng nhập
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        // Kiểm tra nếu đã đăng nhập và có user data
        if (authState.isLoggedIn && authState.user != null) {
          final user = authState.user!;

          // Lấy số từ email (split by @)
          String emailPrefix = '';
          emailPrefix = user.email.split('@').first;

          // Lấy fullName
          String displayName = user.fullName;

          return Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$emailPrefix\n$displayName',
                  style: TextStyle(
                    color: appBarFgColor,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }

        // Nếu chưa đăng nhập hoặc đang loading, hiển thị title mặc định
        return Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: appBarFgColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context, bool isTablet) {
    final double size = isTablet ? 20 : 18;

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1877F2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: Colors.white,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    final actions = <Widget>[];

    // Search Button
    if (widget.showSearchButton) {
      actions.add(
        Container(
          margin: EdgeInsets.only(right: isTablet ? 8 : 4),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_rounded,
                color: foregroundColor.withOpacity(0.8),
                size: isTablet ? 22 : 20,
              ),
            ),
            onPressed: _toggleSearch,
            tooltip: 'Tìm kiếm',
          ),
        ),
      );
    }

    // Notification Button
    if (widget.showNotificationButton) {
      actions.add(
        Container(
          margin: EdgeInsets.only(right: isTablet ? 8 : 4),
          child: _buildNotificationButton(
            context,
            foregroundColor,
            isTablet,
            isDark,
          ),
        ),
      );
    }

    // Additional Actions
    if (widget.additionalActions != null) {
      actions.addAll(widget.additionalActions!);
    }

    // More Options Menu
    actions.add(
      Container(
        margin: EdgeInsets.only(right: isTablet ? 16 : 12),
        child: _buildMoreOptionsMenu(
          context,
          foregroundColor,
          isTablet,
          isDark,
        ),
      ),
    );

    return actions;
  }

  Widget _buildMoreOptionsMenu(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    return PopupMenuButton<String>(
      offset: Offset(0, isTablet ? 60 : 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 10 : 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: foregroundColor.withOpacity(0.8),
          size: isTablet ? 22 : 20,
        ),
      ),
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'about',
              height: isTablet ? 50 : 44,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: foregroundColor.withOpacity(0.7),
                    size: isTablet ? 22 : 20,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Text(
                    'Giới thiệu',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'help',
              height: isTablet ? 50 : 44,
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: foregroundColor.withOpacity(0.7),
                    size: isTablet ? 22 : 20,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Text(
                    'Trợ giúp',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
      onSelected: (String value) {
        switch (value) {
          case 'about':
            context.pushNamed('about');
            break;
          case 'help':
            context.pushNamed('help');
            break;
        }
      },
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    Color foregroundColor,
    bool isTablet,
    bool isDark,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: foregroundColor.withOpacity(0.8),
              size: isTablet ? 22 : 20,
            ),
          ),
          onPressed:
              widget.onNotificationTap ??
              () => context.pushNamed('notifications'),
          tooltip: 'Thông báo',
        ),

        if (widget.notificationCount > 0)
          Positioned(
            right: isTablet ? 10 : 8,
            top: isTablet ? 10 : 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 8 : 6,
                vertical: isTablet ? 4 : 3,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF4757), const Color(0xFFFF6B7A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4757).withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: BoxConstraints(
                minWidth: isTablet ? 24 : 20,
                minHeight: isTablet ? 20 : 16,
              ),
              child: Text(
                widget.notificationCount > 99
                    ? '99+'
                    : widget.notificationCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 11 : 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
