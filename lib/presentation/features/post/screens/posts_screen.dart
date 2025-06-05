import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/enhanced_search_section.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/loading_state.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/pagination_section.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/posts/post_card.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// Enum for Post Types
enum PostType {
  all('Tất cả', Icons.view_list),
  findLost('Tìm đồ thất lạc', Icons.search),
  foundItem('Nhặt đồ thất lạc', Icons.help_outline),
  giveAway('Gửi đồ cũ', Icons.volunteer_activism),
  freePost('Bài đăng tự do', Icons.edit_note);

  const PostType(this.label, this.icon);
  final String label;
  final IconData icon;
}

// Enum for Sort Order
enum SortOrder {
  newest('Mới nhất', Icons.arrow_downward),
  oldest('Cũ nhất', Icons.arrow_upward);

  const SortOrder(this.label, this.icon);
  final String label;
  final IconData icon;
}

// State class for Posts
class PostsState {
  final List<Map<String, dynamic>> allPosts;
  final List<Map<String, dynamic>> displayedPosts;
  final bool isLoading;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final PostType selectedType;
  final SortOrder selectedSort;
  final String searchQuery;

  PostsState({
    required this.allPosts,
    required this.displayedPosts,
    required this.isLoading,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.selectedType,
    required this.selectedSort,
    required this.searchQuery,
  });

  PostsState copyWith({
    List<Map<String, dynamic>>? allPosts,
    List<Map<String, dynamic>>? displayedPosts,
    bool? isLoading,
    int? totalPages,
    int? currentPage,
    int? pageSize,
    PostType? selectedType,
    SortOrder? selectedSort,
    String? searchQuery,
  }) {
    return PostsState(
      allPosts: allPosts ?? this.allPosts,
      displayedPosts: displayedPosts ?? this.displayedPosts,
      isLoading: isLoading ?? this.isLoading,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      selectedType: selectedType ?? this.selectedType,
      selectedSort: selectedSort ?? this.selectedSort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Hooks for Posts functionality
class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier()
    : super(
        PostsState(
          allPosts: [],
          displayedPosts: [],
          isLoading: false,
          totalPages: 0,
          currentPage: 1,
          pageSize: 10,
          selectedType: PostType.all,
          selectedSort: SortOrder.newest,
          searchQuery: '',
        ),
      ) {
    _initializeMockData();
    loadPage(1);
  }

  void _initializeMockData() {
    final List<Map<String, dynamic>> mockPosts = [
      {
        'id': '1',
        'title': 'Tìm chiếc ví da màu nâu bị mất tại quận 1',
        'content':
            'Mình bị mất chiếc ví da màu nâu hôm qua tại khu vực quận 1, gần chợ Bến Thành. Ví có chứa CMND và một số giấy tờ quan trọng. Ai nhặt được xin liên hệ mình nhé!',
        'type': 'findLost',
        'location': 'Quận 1, TP.HCM',
        'images': [
          'https://dummyimage.com/600x400/000/fff',
          'https://dummyimage.com/600x400/000/fff',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        'author': 'Nguyễn Văn A',
        'authorAvatar': '',
        'contactInfo': '0901234567',
        'rewardOffered': '500,000đ',
        'tags': ['ví', 'da', 'nâu', 'quận 1', 'chợ bến thành'],
      },
      {
        'id': '2',
        'title': 'Nhặt được điện thoại iPhone tại công viên Tao Đàn',
        'content':
            'Mình vừa nhặt được chiếc iPhone tại công viên Tao Đàn lúc 15h chiều nay. Điện thoại có case màu xanh, còn pin. Chủ nhân liên hệ mình để lấy lại nhé!',
        'type': 'foundItem',
        'location': 'Quận 1, TP.HCM',
        'images': ['https://dummyimage.com/600x400/000/fff'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
        'author': 'Trần Thị B',
        'authorAvatar': '',
        'contactInfo': '0912345678',
        'tags': ['iphone', 'điện thoại', 'công viên', 'tao đàn', 'case xanh'],
      },
    ];

    for (int i = 3; i <= 100; i++) {
      final postTypes = ['findLost', 'foundItem', 'giveAway', 'freePost'];
      final selectedType = postTypes[(i % 4)];
      mockPosts.add({
        'id': '$i',
        'title': 'Bài đăng số $i - ${_getTypeLabel(selectedType)}',
        'content':
            'Nội dung mô tả chi tiết cho bài đăng số $i. Đây là nội dung mẫu để test phân trang và tìm kiếm. Bài viết này có nhiều thông tin hữu ích.',
        'type': selectedType,
        'location': 'Quận ${(i % 12) + 1}, TP.HCM',
        'images':
            selectedType == 'freePost'
                ? []
                : ['https://dummyimage.com/600x400/000/fff'],
        'createdAt': DateTime.now().subtract(Duration(hours: i)),
        'author': 'Người dùng $i',
        'authorAvatar': '',
        'contactInfo': '090123456${i % 10}',
        'tags': ['tag$i', 'test', selectedType],
        if (selectedType == 'findLost' || selectedType == 'foundItem')
          'rewardOffered': '${(i * 100)}000đ',
      });
    }

    state = state.copyWith(allPosts: mockPosts);
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'findLost':
        return 'Tìm đồ thất lạc';
      case 'foundItem':
        return 'Nhặt đồ thất lạc';
      case 'giveAway':
        return 'Gửi đồ cũ';
      case 'freePost':
        return 'Bài đăng tự do';
      default:
        return 'Khác';
    }
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    List<Map<String, dynamic>> filtered = List.from(state.allPosts);

    if (state.selectedType != PostType.all) {
      filtered =
          filtered
              .where((post) => post['type'] == state.selectedType.name)
              .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase().trim();
      filtered =
          filtered.where((post) => _searchInAllFields(post, query)).toList();
    }

    filtered.sort((a, b) {
      switch (state.selectedSort) {
        case SortOrder.newest:
          return (b['createdAt'] as DateTime).compareTo(
            a['createdAt'] as DateTime,
          );
        case SortOrder.oldest:
          return (a['createdAt'] as DateTime).compareTo(
            b['createdAt'] as DateTime,
          );
      }
    });

    return filtered;
  }

  bool _searchInAllFields(Map<String, dynamic> post, String query) {
    final searchFields = [
      post['title'].toString().toLowerCase(),
      post['content'].toString().toLowerCase(),
      post['location'].toString().toLowerCase(),
      post['author'].toString().toLowerCase(),
    ];

    if (post['tags'] != null) {
      searchFields.addAll(
        (post['tags'] as List).map((tag) => tag.toString().toLowerCase()),
      );
    }

    final queryWords =
        query.split(' ').where((word) => word.isNotEmpty).toList();
    return searchFields.any(
      (field) =>
          field.contains(query) ||
          queryWords.every((word) => field.contains(word)),
    );
  }

  Future<void> loadPage(int page) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    final filteredPosts = _getFilteredPosts();
    final totalPages = (filteredPosts.length / state.pageSize).ceil();

    final startIndex = (page - 1) * state.pageSize;
    final endIndex = startIndex + state.pageSize;

    final pageData = filteredPosts.sublist(
      startIndex,
      endIndex > filteredPosts.length ? filteredPosts.length : endIndex,
    );

    state = state.copyWith(
      displayedPosts: pageData,
      currentPage: page,
      totalPages: totalPages,
      isLoading: false,
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadPage(1);
  }

  void updateTypeFilter(PostType type) {
    state = state.copyWith(selectedType: type);
    loadPage(1);
  }

  void updateSortFilter(SortOrder sort) {
    state = state.copyWith(selectedSort: sort);
    loadPage(1);
  }

  Future<void> refresh() async {
    await loadPage(state.currentPage);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages && page != state.currentPage) {
      loadPage(page);
    }
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      loadPage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      loadPage(state.currentPage - 1);
    }
  }
}

// Riverpod Provider
final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});

// Custom hooks
PostsState usePostsState(WidgetRef ref) {
  return ref.watch(postsProvider);
}

PostsNotifier usePostsNotifier(WidgetRef ref) {
  return ref.read(postsProvider.notifier);
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final PostsNotifier postsNotifier;

  const EmptyState({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.postsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: theme.hintColor,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () {
              postsNotifier.updateSearchQuery('');
              postsNotifier.updateTypeFilter(PostType.all);
              postsNotifier.updateSortFilter(SortOrder.newest);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Đặt lại bộ lọc'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Posts Screen
class PostsScreen extends HookConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isTablet = context.isTablet;
    final screenSize = context.screenSize;

    final postsState = usePostsState(ref);
    final postsNotifier = usePostsNotifier(ref);

    void handleCreatePost() {
      context.pushNamed('create-post');
    }

    void handlePostTap(Map<String, dynamic> post) {
      context.pushNamed('post-detail', pathParameters: {'id': post['id']});
    }

    bool hasImages(Map<String, dynamic> post) {
      return post['type'] != 'freePost' &&
          post['images'] != null &&
          (post['images'] as List).isNotEmpty &&
          (post['images'] as List).any((img) => img.toString().isNotEmpty);
    }

    Color getTypeColor(PostType type) {
      switch (type) {
        case PostType.findLost:
          return Colors.red;
        case PostType.foundItem:
          return Colors.green;
        case PostType.giveAway:
          return Colors.blue;
        case PostType.freePost:
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    return SmartScaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await postsNotifier.refresh();
            if (context.mounted) {
              context.showSuccessSnackBar('Đã cập nhật danh sách bài đăng');
            }
          },
          child: Column(
            children: [
              EnhancedSearchSection(
                isTablet: isTablet,
                theme: theme,
                colorScheme: colorScheme,
                ref: ref,
                searchController: searchController,
                searchFocusNode: searchFocusNode,
                postsState: postsState,
                postsNotifier: postsNotifier,
              ),
              Expanded(
                child:
                    postsState.displayedPosts.isEmpty && !postsState.isLoading
                        ? EmptyState(
                          isTablet: isTablet,
                          theme: theme,
                          colorScheme: colorScheme,
                          postsNotifier: postsNotifier,
                        )
                        : Column(
                          children: [
                            Expanded(
                              child:
                                  postsState.isLoading
                                      ? LoadingState(
                                        isTablet: isTablet,
                                        screenSize: screenSize,
                                        colorScheme: colorScheme,
                                      )
                                      : ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet ? 32 : 16,
                                          vertical: isTablet ? 16 : 8,
                                        ),
                                        itemCount:
                                            postsState.displayedPosts.length,
                                        itemBuilder: (context, index) {
                                          return PostCard(
                                            post:
                                                postsState
                                                    .displayedPosts[index],
                                            isTablet: isTablet,
                                            theme: theme,
                                            colorScheme: colorScheme,
                                            onTap: handlePostTap,
                                            getTypeColor: getTypeColor,
                                            hasImages: hasImages,
                                          );
                                        },
                                      ),
                            ),
                            if (postsState.totalPages > 1)
                              PaginationSection(
                                isTablet: isTablet,
                                colorScheme: colorScheme,
                                postsState: postsState,
                                postsNotifier: postsNotifier,
                              ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: handleCreatePost,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('Đăng bài'),
        ),
      ),
    );
  }
}
