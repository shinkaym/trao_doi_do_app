import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_bottom_action_bar.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_content_section.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_detail_states.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_image_gallery.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_interests_section.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/post-detail/post_items_section.dart';

class PostDetailScreen extends HookConsumerWidget {
  final String postSlug;

  const PostDetailScreen({super.key, required this.postSlug});

  bool isPostAuthor(PostDetail post, User? currentUser) {
    if (currentUser == null) return false;
    return post.authorID == currentUser.id;
  }

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
    final isBookmarked = useState(false);
    final showFullContent = useState(false);

    // Provider state
    final postDetailState = ref.watch(postDetailProvider);
    final authState = ref.watch(authProvider);
    final interestState = ref.watch(interestProvider);

    // Load post detail on first build
    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(postDetailProvider.notifier).getPostDetail(postSlug);
        }
      });
      return () {
        // Add mounted check before cleanup
        if (context.mounted) {
          ref.read(postDetailProvider.notifier).clearPost();
        }
      };
    }, [postSlug]);

    // Animation trigger when post is loaded
    useEffect(() {
      if (postDetailState.post != null && !postDetailState.isLoading) {
        if (context.mounted && animationController.isAnimating == false) {
          animationController.forward();
        }
      }
      return null;
    }, [postDetailState.post, postDetailState.isLoading]);

    // Helper functions to check interest status
    bool isUserInterested(List<PostInterest> interests, int? userID) {
      if (userID == null) return false;
      return interests.any((interest) => interest.userID == userID);
    }

    int? getUserInterestId(List<PostInterest> interests, int? userID) {
      if (userID == null) return null;
      try {
        final userInterest = interests.firstWhere(
          (interest) => interest.userID == userID,
        );
        return userInterest.id;
      } catch (e) {
        return null;
      }
    }

    void handleBookmark() {
      if (!context.mounted) return;

      isBookmarked.value = !isBookmarked.value;
      if (isBookmarked.value) {
        context.showSuccessSnackBar('Đã lưu bài đăng');
      } else {
        context.showWarningSnackBar('Đã bỏ lưu bài đăng');
      }
    }

    void handleShare() {
      if (!context.mounted) return;
      context.showInfoSnackBar('Đã sao chép link bài đăng');
    }

    void handleChatTap(int interestId) {
      context.pushNamed(
        'interest-chat',
        pathParameters: {'interestId': interestId.toString()},
      );
    }

    void handleInterest() async {
      if (!context.mounted) return;

      final post = postDetailState.post;
      final currentUser = authState.user;

      if (post == null || currentUser == null) {
        if (context.mounted) {
          context.showErrorSnackBar('Vui lòng đăng nhập để quan tâm bài đăng');
        }
        return;
      }

      if (!interestState.isLoading) {
        final userInterested = isUserInterested(post.interests, currentUser.id);
        final action =
            userInterested ? InterestAction.cancel : InterestAction.create;

        await ref
            .read(interestProvider.notifier)
            .toggleInterest(post.id!, action);

        if (!context.mounted) return;

        final updatedState = ref.read(interestProvider);

        if (updatedState.result?.message != null) {
          HapticFeedback.lightImpact();

          if (context.mounted) {
            ref.read(postDetailProvider.notifier).getPostDetail(postSlug);
            ref.read(interestProvider.notifier).clearMessages();
          }
        } else if (updatedState.failure != null) {
          if (context.mounted) {
            context.showErrorSnackBar(updatedState.failure!.message);
            ref.read(interestProvider.notifier).clearMessages();
          }
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
        postSlug,
      );
    }

    // No post found
    if (postDetailState.post == null) {
      return PostDetailStates.buildNotFoundState(colorScheme, context);
    }

    final post = postDetailState.post!;
    final userInterested = isUserInterested(post.interests, authState.user?.id);
    final currentUserInterestId = getUserInterestId(
      post.interests,
      authState.user?.id,
    );
    final interestCount = post.interests.length;

    final images = post.images.isNotEmpty ? post.images : [''];

    useEffect(() {
      if (authState.user != null) {
        userInterestId.value = getUserInterestId(
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
              backgroundColor: colorScheme.primary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Tăng độ trong suốt
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
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: handleBookmark,
                    icon: Icon(
                      isBookmarked.value
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: isBookmarked.value ? Colors.amber : Colors.white,
                    ),
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
            if (post.items.isNotEmpty)
              SliverToBoxAdapter(child: PostItemsSection(items: post.items)),

            // Interests section (if available) - UPDATED
            if (post.interests.isNotEmpty)
              SliverToBoxAdapter(
                child: PostInterestsSection(interests: post.interests),
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
        isPostOwner: isPostAuthor(post, authState.user),
        post: post,
        postSlug: postSlug
      ),
    );
  }
}
