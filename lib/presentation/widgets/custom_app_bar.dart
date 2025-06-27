import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/search_suggestions_overlay.dart';

class CustomAppBar extends HookConsumerWidget implements PreferredSizeWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final isSearchMode = useState(false);
    final overlayEntry = useState<OverlayEntry?>(null);

    // Animation hooks
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final searchAnimation = useMemoized(
      () =>
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      [animationController],
    );

    // Text controller and focus node hooks
    final internalSearchController = useTextEditingController();
    final searchControllerToUse = searchController ?? internalSearchController;
    final searchFocusNode = useFocusNode();

    // Utility functions
    void hideOverlay() {
      overlayEntry.value?.remove();
      overlayEntry.value = null;
    }

    void showOverlay() {
      hideOverlay();

      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);

      overlayEntry.value = OverlayEntry(
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
                        hideOverlay();
                        navigateToPostDetail(
                          context,
                          post,
                          isSearchMode,
                          animationController,
                          ref,
                        );
                      },
                      onViewAll: () {
                        hideOverlay();
                        navigateToPostsWithSearch(
                          context,
                          searchState.query,
                          isSearchMode,
                          animationController,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
      );

      overlay.insert(overlayEntry.value!);
    }

    void toggleSearch() {
      isSearchMode.value = !isSearchMode.value;
      if (isSearchMode.value) {
        animationController.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchFocusNode.requestFocus();
        });
      } else {
        animationController.reverse();
        searchControllerToUse.clear();
        searchFocusNode.unfocus();
        hideOverlay();
        // Clear search suggestions
        ref.read(searchSuggestionsProvider.notifier).clear();
      }
    }

    void performSearch(String query) {
      if (onSearch != null) {
        onSearch!(query);
      }

      // Trigger search suggestions
      ref.read(searchSuggestionsProvider.notifier).searchWithDebounce(query);

      if (query.trim().isNotEmpty && searchFocusNode.hasFocus) {
        showOverlay();
      } else {
        hideOverlay();
      }
    }

    // Focus listener effect
    useEffect(() {
      void onFocusChange() {
        if (searchFocusNode.hasFocus && searchControllerToUse.text.isNotEmpty) {
          showOverlay();
        } else {
          hideOverlay();
        }
      }

      searchFocusNode.addListener(onFocusChange);
      return () => searchFocusNode.removeListener(onFocusChange);
    }, [searchFocusNode, searchControllerToUse]);

    // Cleanup effect
    useEffect(() {
      return () {
        hideOverlay();
      };
    }, []);

    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;

    // Facebook-inspired colors
    final appBarBgColor =
        backgroundColor ?? (isDark ? const Color(0xFF1B1B1B) : Colors.white);
    final appBarFgColor =
        foregroundColor ?? (isDark ? Colors.white : const Color(0xFF1C1E21));
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
            bottom != null
                ? PreferredSize(
                  preferredSize: bottom!.preferredSize,
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
                    child: bottom!,
                  ),
                )
                : null,
        leading: buildLeading(
          context,
          isTablet,
          isDark,
          appBarBgColor,
          appBarFgColor,
          isSearchMode.value,
          toggleSearch,
        ),
        title: buildTitle(
          context,
          isTablet,
          isDark,
          appBarBgColor,
          appBarFgColor,
          isSearchMode.value,
          searchAnimation,
          searchControllerToUse,
          searchFocusNode,
          performSearch,
          hideOverlay,
          ref,
          title,
          searchHint ?? 'Tìm kiếm...',
        ),
        actions:
            isSearchMode.value
                ? []
                : buildActions(
                  context,
                  appBarFgColor,
                  isTablet,
                  isDark,
                  toggleSearch,
                  showNotificationButton,
                  notificationCount,
                  onNotificationTap,
                  additionalActions,
                ),
        titleSpacing: 0,
      ),
    );
  }
}

// Helper functions moved outside the widget
Widget? buildLeading(
  BuildContext context,
  bool isTablet,
  bool isDark,
  Color appBarBgColor,
  Color appBarFgColor,
  bool isSearchMode,
  VoidCallback toggleSearch,
) {
  if (isSearchMode) {
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
        onPressed: toggleSearch,
      ),
    );
  }

  // Add other leading logic here...
  return Container(
    margin: EdgeInsets.only(left: isTablet ? 16 : 12),
    child: buildLogo(context, isTablet),
  );
}

Widget? buildTitle(
  BuildContext context,
  bool isTablet,
  bool isDark,
  Color appBarBgColor,
  Color appBarFgColor,
  bool isSearchMode,
  Animation<double> searchAnimation,
  TextEditingController searchController,
  FocusNode searchFocusNode,
  Function(String) performSearch,
  VoidCallback hideOverlay,
  WidgetRef ref,
  String title,
  String searchHint,
) {
  if (isSearchMode) {
    return AnimatedBuilder(
      animation: searchAnimation,
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
                    controller: searchController,
                    focusNode: searchFocusNode,
                    style: TextStyle(
                      color: appBarFgColor,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    decoration: InputDecoration(
                      hintText: searchHint,
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
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: appBarFgColor.withOpacity(0.6),
                                  size: isTablet ? 22 : 20,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  hideOverlay();
                                  ref
                                      .read(searchSuggestionsProvider.notifier)
                                      .clear();
                                },
                              )
                              : Icon(
                                Icons.search_rounded,
                                color: appBarFgColor.withOpacity(0.6),
                                size: isTablet ? 22 : 20,
                              ),
                    ),
                    onChanged: performSearch,
                    onSubmitted: (value) {
                      performSearch(value);
                      navigateToPostsWithSearch(
                        context,
                        value,
                        useState(true),
                        useAnimationController(),
                      );
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

  // Display dynamic title based on login status
  return Consumer(
    builder: (context, ref, child) {
      final authState = ref.watch(authProvider);

      // Check if logged in and has user data
      if (authState.isLoggedIn && authState.user != null) {
        final user = authState.user!;

        // Get number from email (split by @)
        String emailPrefix = '';
        emailPrefix = user.email.split('@').first;

        // Get fullName
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

      // If not logged in or loading, show default title
      return Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
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

Widget buildLogo(BuildContext context, bool isTablet) {
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

List<Widget> buildActions(
  BuildContext context,
  Color foregroundColor,
  bool isTablet,
  bool isDark,
  VoidCallback toggleSearch,
  bool showNotificationButton,
  int notificationCount,
  VoidCallback? onNotificationTap,
  List<Widget>? additionalActions,
) {
  final actions = <Widget>[];

  // Search Button
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
        onPressed: toggleSearch,
        tooltip: 'Tìm kiếm',
      ),
    ),
  );

  // Notification Button
  if (showNotificationButton) {
    actions.add(
      Container(
        margin: EdgeInsets.only(right: isTablet ? 8 : 4),
        child: buildNotificationButton(
          context,
          foregroundColor,
          isTablet,
          isDark,
          notificationCount,
          onNotificationTap,
        ),
      ),
    );
  }

  // Additional Actions
  if (additionalActions != null) {
    actions.addAll(additionalActions);
  }

  // More Options Menu
  actions.add(
    Container(
      margin: EdgeInsets.only(right: isTablet ? 16 : 12),
      child: buildMoreOptionsMenu(context, foregroundColor, isTablet, isDark),
    ),
  );

  return actions;
}

Widget buildNotificationButton(
  BuildContext context,
  Color foregroundColor,
  bool isTablet,
  bool isDark,
  int notificationCount,
  VoidCallback? onNotificationTap,
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
            onNotificationTap ??
            () => context.pushNamed(RouteNames.notifications),
        tooltip: 'Thông báo',
      ),
      if (notificationCount > 0)
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
              notificationCount > 99 ? '99+' : notificationCount.toString(),
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

Widget buildMoreOptionsMenu(
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

// Navigation helper functions
void navigateToPostDetail(
  BuildContext context,
  dynamic post,
  ValueNotifier<bool> isSearchMode,
  AnimationController animationController,
  WidgetRef ref,
) {
  context.pushNamed(
    RouteNames.postDetail,
    pathParameters: {'slug': post.slug.toString()},
  );
  // Toggle search mode
  isSearchMode.value = false;
  animationController.reverse();
}

void navigateToPostsWithSearch(
  BuildContext context,
  String searchQuery,
  ValueNotifier<bool> isSearchMode,
  AnimationController animationController,
) {
  if (searchQuery.trim().isEmpty) return;

  context.pushNamed(
    RouteNames.posts,
    extra: {'search': searchQuery.trim(), 'autoFocus': false},
  );

  // Toggle search mode
  isSearchMode.value = false;
  animationController.reverse();
}
