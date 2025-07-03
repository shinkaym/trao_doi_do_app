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
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: 0,
        right: 0,
        bottom: 5,
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: Material(
            color: Colors.transparent,
            child: Consumer(
              builder: (context, ref, child) {
                final searchState = ref.watch(searchSuggestionsProvider);

                if (searchState.query.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: SearchSuggestionsOverlay(
                    suggestions: searchState.suggestions,
                    isLoading: searchState.isLoading,
                    searchQuery: searchState.query,
                    onPostTap: (post) {
                      _hideOverlay();
                      _navigateToPostDetail(context, post);
                    },
                    onViewAll: () {
                      _hideOverlay();
                      _navigateToPostsWithSearch(
                        context,
                        searchState.query,
                      );
                    },
                  ),
                );
              },
            ),
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

    // Facebook-inspired colors
    final appBarBgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1B1B1B) : Colors.white);
    final appBarFgColor = widget.foregroundColor ??
        (isDark ? Colors.white : const Color(0xFF1C1E21));
    final toolbarHeight = isTablet ? 70.0 : 60.0;

    // Create SystemUiOverlayStyle once
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
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        bottom: widget.bottom != null
            ? PreferredSize(
                preferredSize: widget.bottom!.preferredSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: appBarBgColor,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
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
        leading: _buildLeading(context, appBarBgColor, appBarFgColor),
        title: _buildTitle(context, appBarBgColor, appBarFgColor),
        actions: _isSearchMode ? [] : _buildActions(context, appBarFgColor),
        titleSpacing: 0,
      ),
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    Color appBarBgColor,
    Color appBarFgColor,
  ) {
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;

    if (_isSearchMode) {
      return AppBarBackButton(
        onPressed: _toggleSearch,
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        isDark: isDark,
        isTablet: isTablet,
      );
    }

    if (widget.showBackButton) {
      return AppBarBackButton(
        onPressed: widget.onBackPressed ??
            () {
              if (context.canPop) {
                context.pop();
              } else {
                context.goNamed(RouteNames.home);
              }
            },
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        isDark: isDark,
        isTablet: isTablet,
      );
    }

    return Container(
      margin: EdgeInsets.only(left: isTablet ? 16 : 12),
      child: AppBarLogo(isTablet: isTablet),
    );
  }

  Widget? _buildTitle(
    BuildContext context,
    Color appBarBgColor,
    Color appBarFgColor,
  ) {
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;

    if (_isSearchMode) {
      return AppBarSearchField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        animation: _searchAnimation,
        hintText: widget.searchHint ?? 'Tìm kiếm...',
        foregroundColor: appBarFgColor,
        isDark: isDark,
        isTablet: isTablet,
        onChanged: (value) {
          setState(() {});
          _performSearch(value);
        },
        onSubmitted: (value) {
          _performSearch(value);
          _navigateToPostsWithSearch(context, value);
        },
        onClear: () {
          _searchController.clear();
          _hideOverlay();
          ref.read(searchSuggestionsProvider.notifier).clear();
          setState(() {});
        },
      );
    }

    return AppBarTitle(
      title: widget.title,
      foregroundColor: appBarFgColor,
      isTablet: isTablet,
    );
  }

  List<Widget> _buildActions(BuildContext context, Color foregroundColor) {
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;
    final actions = <Widget>[];

    // Search Button
    if (widget.showSearchButton) {
      actions.add(
        AppBarSearchButton(
          onPressed: _toggleSearch,
          foregroundColor: foregroundColor,
          isDark: isDark,
          isTablet: isTablet,
        ),
      );
    }

    // Notification Button
    if (widget.showNotificationButton) {
      actions.add(
        AppBarNotificationButton(
          onPressed: widget.onNotificationTap ??
              () => context.pushNamed(RouteNames.notifications),
          foregroundColor: foregroundColor,
          isDark: isDark,
          isTablet: isTablet,
        ),
      );
    }

    // Additional Actions
    if (widget.additionalActions != null) {
      actions.addAll(widget.additionalActions!);
    }

    // More Options Menu
    actions.add(
      AppBarMoreOptionsMenu(
        foregroundColor: foregroundColor,
        isDark: isDark,
        isTablet: isTablet,
      ),
    );

    return actions;
  }
}

// Separated Widgets

class AppBarLogo extends StatelessWidget {
  final bool isTablet;

  const AppBarLogo({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
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
}

class AppBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isDark;
  final bool isTablet;

  const AppBarBackButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isTablet ? 12 : 8),
      child: IconButton(
        icon: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: foregroundColor,
            size: isTablet ? 20 : 18,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class AppBarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> animation;
  final String hintText;
  final Color foregroundColor;
  final bool isDark;
  final bool isTablet;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const AppBarSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.animation,
    required this.hintText,
    required this.foregroundColor,
    required this.isDark,
    required this.isTablet,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            right: isTablet ? 16 : 12,
            top: isTablet ? 12 : 8,
            bottom: isTablet ? 12 : 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: isTablet ? 46 : 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: foregroundColor.withOpacity(0.6),
                        fontSize: isTablet ? 16 : 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 14 : 12,
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: foregroundColor.withOpacity(0.6),
                                size: isTablet ? 22 : 20,
                              ),
                              onPressed: onClear,
                            )
                          : Icon(
                              Icons.search_rounded,
                              color: foregroundColor.withOpacity(0.6),
                              size: isTablet ? 22 : 20,
                            ),
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
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
}

class AppBarTitle extends ConsumerWidget {
  final String title;
  final Color foregroundColor;
  final bool isTablet;

  const AppBarTitle({
    super.key,
    required this.title,
    required this.foregroundColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show user info if logged in
    if (authState.isLoggedIn && authState.user != null) {
      final user = authState.user!;
      String emailPrefix = user.email.split('@').first;
      String displayName = user.fullName;

      return Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$emailPrefix\n$displayName',
              style: TextStyle(
                color: foregroundColor,
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

    // Show default title if not logged in
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: foregroundColor,
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
}

class AppBarSearchButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color foregroundColor;
  final bool isDark;
  final bool isTablet;

  const AppBarSearchButton({
    super.key,
    required this.onPressed,
    required this.foregroundColor,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 8 : 4),
      child: IconButton(
        icon: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: isDark
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
        onPressed: onPressed,
        tooltip: 'Tìm kiếm',
      ),
    );
  }
}

class AppBarNotificationButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final Color foregroundColor;
  final bool isDark;
  final bool isTablet;

  const AppBarNotificationButton({
    super.key,
    required this.onPressed,
    required this.foregroundColor,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch unread notification count
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Container(
      margin: EdgeInsets.only(right: isTablet ? 8 : 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: isDark
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
            onPressed: onPressed,
            tooltip: 'Thông báo',
          ),
          // Badge for unread notifications
          if (unreadCount > 0)
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
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
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
      ),
    );
  }
}

class AppBarMoreOptionsMenu extends StatelessWidget {
  final Color foregroundColor;
  final bool isDark;
  final bool isTablet;

  const AppBarMoreOptionsMenu({
    super.key,
    required this.foregroundColor,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 16 : 12),
      child: PopupMenuButton<String>(
        offset: Offset(0, isTablet ? 60 : 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: isDark
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
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: RouteNames.help,
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
          context.pushNamed(value);
        },
      ),
    );
  }
}