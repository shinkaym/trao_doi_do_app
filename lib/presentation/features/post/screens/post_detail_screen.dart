import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/usecases/params/transaction_query.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_list_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_bottom_action_bar.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_content_section.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_detail_helpers.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_detail_states.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_image_gallery.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_interests_disolay.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_items_section.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/transaction_item_selection_bottom_sheet.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/transaction_management_section.dart';

class PostDetailScreen extends HookConsumerWidget {
  final String? postSlug;
  final int? postId;

  const PostDetailScreen({super.key, this.postSlug, this.postId})
    : assert(
        postSlug != null || postId != null,
        'Either postSlug or postId must be provided',
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInterestId = useState<int?>(null);

    // Hooks
    final pageController = usePageController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    // State
    final currentImageIndex = useState(0);
    final showFullContent = useState(false);

    // Provider state
    final postDetailState = ref.watch(postDetailProvider);
    final authState = ref.watch(authProvider);
    final interestState = ref.watch(interestProvider);
    final transactionsNotifier = ref.read(transactionsListProvider.notifier);
    ref.watch(settingsProvider);
    ref.watch(transactionsListProvider);

    // Tính currentUserInterestId từ post data
    final post = postDetailState.post;
    final currentUser = authState.user;
    final currentUserInterestId =
        post != null && currentUser != null
            ? PostDetailHelpers.getUserInterestId(
              post.interests,
              currentUser.id,
            )
            : null;

    // Watch interestDetailProvider nếu có currentUserInterestId
    final interestDetailState =
        currentUserInterestId != null
            ? ref.watch(interestDetailProvider(currentUserInterestId))
            : null;
    final interestDetail = interestDetailState?.interestDetail;

    // Load post detail on first build
    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          if (postSlug != null) {
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(slug: postSlug!);
          } else if (postId != null) {
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(postID: postId!);
          }
        }
      });
      return () {
        // Add mounted check before cleanup
        if (context.mounted) {
          ref.read(postDetailProvider.notifier).clearPost();
        }
      };
    }, [postSlug, postId]);

    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(settingsProvider.notifier).loadSettings();
        }
      });
      return null;
    }, []);

    // Load interest detail khi có currentUserInterestId
    useEffect(() {
      if (currentUserInterestId != null &&
          interestDetailState?.interestDetail == null &&
          !interestDetailState!.isLoading) {
        Future.microtask(() {
          ref
              .read(interestDetailProvider(currentUserInterestId).notifier)
              .loadInterestDetail(currentUserInterestId);
        });
      }
      return null;
    }, [currentUserInterestId]);

    // Animation trigger when post is loaded
    useEffect(() {
      if (postDetailState.post != null && !postDetailState.isLoading) {
        if (context.mounted && animationController.isAnimating == false) {
          animationController.forward();
        }
      }
      return null;
    }, [postDetailState.post, postDetailState.isLoading]);

    useEffect(() {
      final interestState = ref.read(interestProvider);

      if (interestState.result?.message != null) {
        Future.microtask(() {
          if (context.mounted) {
            HapticFeedback.lightImpact();
            context.showSuccessSnackBar(interestState.result!.message);

            // Refresh post detail
            final post = postDetailState.post;
            final slugToUse = post?.slug ?? postSlug;
            if (slugToUse != null) {
              ref
                  .read(postDetailProvider.notifier)
                  .getPostDetail(slug: slugToUse);
            }
            ref.read(interestProvider.notifier).clearMessages();
          }
        });
      } else if (interestState.failure != null) {
        Future.microtask(() {
          if (context.mounted) {
            context.showErrorSnackBar(interestState.failure!.message);
            ref.read(interestProvider.notifier).clearMessages();
          }
        });
      }
      return null;
    }, [interestState.result, interestState.failure]);

    void handleShare() async {
      if (!context.mounted) return;

      // Lấy domain từ settings
      final domainSetting = ref
          .read(settingsProvider.notifier)
          .findSettingByKey('domain');

      if (domainSetting != null) {
        final domain = domainSetting.value;

        final currentPost = postDetailState.post;
        final slugToUse = currentPost?.slug ?? postSlug;

        if (slugToUse != null) {
          final postLink = '$domain/bai-dang/$slugToUse';

          // Copy link vào clipboard
          await Clipboard.setData(ClipboardData(text: postLink));

          if (context.mounted) {
            context.showSuccessSnackBar('Đã sao chép link bài đăng');
          }
        } else {
          if (context.mounted) {
            context.showErrorSnackBar('Không thể lấy thông tin bài đăng');
          }
        }
      } else {
        if (context.mounted) {
          context.showErrorSnackBar('Không thể lấy thông tin domain');
        }
      }
    }

    void handleChatTap(int interestId) {
      context.pushNamed(
        RouteNames.interestChat,
        pathParameters: {'interestId': interestId.toString()},
      );
    }

    void handleInterest() async {
      if (!context.mounted) return;

      final post = postDetailState.post;
      final currentUser = authState.user;

      if (!interestState.isLoading) {
        final userInterested = PostDetailHelpers.isUserInterested(
          post!.interests,
          currentUser!.id,
        );
        final action =
            userInterested ? InterestAction.cancel : InterestAction.create;

        await ref
            .read(interestProvider.notifier)
            .toggleInterest(post.id!, action);
      }
    }

    // Handle item transaction
    void handleItemTransactionTap() async {
      final post = postDetailState.post;
      final currentUser = authState.user;

      if (post == null ||
          currentUser == null ||
          currentUserInterestId == null) {
        context.showErrorSnackBar('Không thể thực hiện giao dịch');
        return;
      }

      final isPostOwner = PostDetailHelpers.isPostAuthor(post, currentUser);
      if (isPostOwner) {
        context.showInfoSnackBar('Chủ bài viết không thể tạo giao dịch');
        return;
      }

      try {
        final query = TransactionsQuery(
          sort: 'createdAt',
          order: 'DESC',
          postID: post.id,
          searchBy: 'interestID',
          searchValue: currentUserInterestId.toString(),
        );

        await transactionsNotifier.loadTransactions(
          newQuery: query,
          refresh: true,
        );

        final updatedTransactionsState = ref.read(transactionsListProvider);
        final latestTransaction =
            updatedTransactionsState.transactions.isNotEmpty
                ? updatedTransactionsState.transactions.first
                : null;

        final canCreateTransaction =
            latestTransaction == null || latestTransaction.status != 1;

        if (!canCreateTransaction) {
          final waitMessage =
              post.type == PostType.findLost.value
                  ? 'Đợi phản hồi từ chủ bài viết'
                  : 'Đợi yêu cầu mới nhất được phản hồi';

          context.showInfoSnackBar(waitMessage);
          return;
        }

        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (_) => TransactionItemSelectionBottomSheet(
                  postItems: interestDetail?.items ?? [],
                  interestId: currentUserInterestId,
                  postType: post.type,
                  onTransactionSent: () {
                    transactionsNotifier.refresh();
                    // Loại bỏ show SnackBar ở đây - sẽ được handle bởi callback
                  },
                ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          context.showErrorSnackBar('Có lỗi xảy ra khi tải dữ liệu giao dịch');
        }
      }
    }

    void handleViewTransactionsTap() async {
      final post = postDetailState.post;
      final currentUser = authState.user;

      if (post == null ||
          currentUser == null ||
          currentUserInterestId == null) {
        context.showErrorSnackBar('Không thể tải danh sách giao dịch');
        return;
      }

      try {
        final query = TransactionsQuery(
          sort: 'createdAt',
          order: 'DESC',
          postID: post.id,
          searchBy: 'interestID',
          searchValue: currentUserInterestId.toString(),
        );

        await transactionsNotifier.loadTransactions(
          newQuery: query,
          refresh: true,
        );

        final updatedTransactionsState = ref.read(transactionsListProvider);

        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (bottomSheetContext) => TransactionListBottomSheet(
                  transactions: updatedTransactionsState.transactions,
                  isPostOwner: false,
                  postType: post.type,
                  items: interestDetail?.items ?? [],
                  onTransactionUpdated: (updatedTransaction) {
                    if (context.mounted) {
                      transactionsNotifier.refresh();
                    }
                  },
                ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          context.showErrorSnackBar(
            'Có lỗi xảy ra khi tải danh sách giao dịch',
          );
        }
      }
    }

    // UI
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    // Loading state
    if (postDetailState.isLoading && postDetailState.post == null) {
      return PostDetailStates.buildLoadingState(colorScheme, context);
    }

    // Error state
    if (postDetailState.failure != null) {
      return PostDetailStates.buildErrorState(
        postDetailState,
        colorScheme,
        context,
        ref,
        post?.slug ?? postSlug ?? '',
      );
    }

    // No post found
    if (postDetailState.post == null) {
      return PostDetailStates.buildNotFoundState(colorScheme, context);
    }

    final userInterested = PostDetailHelpers.isUserInterested(
      post!.interests,
      authState.user?.id,
    );
    final interestCount = post.interests.length;
    final isPostOwner = PostDetailHelpers.isPostAuthor(post, authState.user);

    final images = post.images.isNotEmpty ? post.images : [''];

    void handleShowAllUsers() {
      final post = postDetailState.post;
      if (post == null || post.interests.isEmpty) return;

      PostDetailHelpers.showAllUsersBottomSheet(
        context,
        post.interests,
        isPostOwner,
      );
    }

    useEffect(() {
      if (authState.user != null) {
        userInterestId.value = PostDetailHelpers.getUserInterestId(
          post.interests,
          authState.user!.id,
        );
      }
      return null;
    }, [post.interests, authState.user?.id]);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar with images
            SliverAppBar(
              expandedHeight: isTablet ? 450 : 350,
              pinned: true,
              backgroundColor: colorScheme.background,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed:
                      () => {
                        if (context.mounted) {context.pop()},
                      },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: handleShare,
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: PostImageGallery(
                  images: images,
                  pageController: pageController,
                  currentImageIndex: currentImageIndex,
                ),
              ),
            ),

            // Post Content
            SliverToBoxAdapter(
              child: PostContentSection(
                post: post,
                showFullContent: showFullContent,
                userInterested: userInterested,
                interestCount: interestCount,
                onInterest: handleInterest,
              ),
            ),

            // Items section (if available)
            if ((interestDetail?.items ?? post.items).isNotEmpty)
              SliverToBoxAdapter(
                child: PostItemsSection(
                  items: post.items,
                  showTransactionButton:
                      !isPostOwner &&
                      userInterested &&
                      (interestDetail?.items ?? post.items).isNotEmpty,
                  onTransactionTap: handleItemTransactionTap,
                  postType: post.type,
                ),
              ),

            if (!isPostOwner &&
                userInterested &&
                post.type < 5 &&
                post.interests.isNotEmpty)
              SliverToBoxAdapter(
                child: TransactionManagementSection(
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  onViewTransactionsTap: handleViewTransactionsTap,
                ),
              ),

            if (post.interests.isNotEmpty)
              SliverToBoxAdapter(
                child: PostInterestsDisplay(
                  interests: post.interests,
                  isPostOwner: isPostOwner,
                  onShowAllUsers: handleShowAllUsers,
                  userID: currentUser!.id,
                ),
              ),

            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: isTablet ? 32 : 24)),
          ],
        ),
      ),
      bottomNavigationBar: PostBottomActionBar(
        userInterested: userInterested,
        interestCount: interestCount,
        onInterest: handleInterest,
        onShare: handleShare,
        interestId: currentUserInterestId ?? userInterestId.value,
        onChatTap: handleChatTap,
        isPostOwner: isPostOwner,
        post: post,
      ),
    );
  }
}
