import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class PostBottomActionBar extends HookConsumerWidget {
  final bool userInterested;
  final int interestCount;
  final VoidCallback onInterest;
  final VoidCallback onShare;
  final int? interestId;
  final Function(int) onChatTap;
  final bool isPostOwner;
  final PostDetail? post;

  const PostBottomActionBar({
    Key? key,
    required this.userInterested,
    required this.interestCount,
    required this.onInterest,
    required this.onShare,
    this.interestId,
    required this.onChatTap,
    this.isPostOwner = false,
    this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chuyển state variables thành hooks
    final isToggling = useState(false);
    final isReposting = useState(false);
    final isDeleting = useState(false);

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final interestState = ref.watch(interestProvider);
    final postState = ref.watch(postProvider);

    // Listen to postState changes để xử lý success/error
    useEffect(() {
      if (postState.successMessage != null) {
        Future.microtask(() {
          if (context.mounted) {
            context.showSuccessSnackBar(postState.successMessage!);

            // Handle navigation for delete action
            if (postState.successMessage!.contains('Xóa bài đăng thành công')) {
              context.pop();
            }

            // Clear loading states
            isToggling.value = false;
            isReposting.value = false;
            isDeleting.value = false;

            // Clear messages
            ref.read(postProvider.notifier).clearMessages();
          }
        });
      } else if (postState.failure != null) {
        Future.microtask(() {
          if (context.mounted) {
            context.showErrorSnackBar(postState.failure!.message);

            // Clear loading states
            isToggling.value = false;
            isReposting.value = false;
            isDeleting.value = false;

            // Clear messages
            ref.read(postProvider.notifier).clearMessages();
          }
        });
      }
      return null;
    }, [postState.successMessage, postState.failure]);

    // Các helper methods cần được định nghĩa trong build method
    bool isCampaignOngoing() {
      if (post == null) return true;

      final postType = PostType.values.firstWhere(
        (type) => type.value == post!.type,
        orElse: () => PostType.all,
      );

      if (postType != PostType.campaign) return true;

      try {
        final campaignInfo = CampaignInfo.fromJson(jsonDecode(post!.info));
        final now = DateTime.now();

        DateTime? startDate;
        DateTime? endDate;

        if (campaignInfo.startDate.isNotEmpty) {
          startDate = DateTime.parse(campaignInfo.startDate);
        }

        if (campaignInfo.endDate.isNotEmpty) {
          endDate = DateTime.parse(campaignInfo.endDate);
        }

        if (startDate != null && endDate != null) {
          return now.isAfter(startDate) && now.isBefore(endDate);
        } else if (startDate != null) {
          return now.isAfter(startDate);
        } else if (endDate != null) {
          return now.isBefore(endDate);
        }

        return true;
      } catch (e) {
        return true;
      }
    }

    String getInterestButtonText(bool isLoading, bool canInterest) {
      if (!canInterest) return 'Không thể quan tâm';
      if (isLoading) return 'Đang xử lý...';
      if (userInterested) return 'Đã quan tâm (${interestCount})';
      return 'Quan tâm (${interestCount})';
    }

    bool canRepost(DateTime createdAt) {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      return difference.inDays >= 7;
    }

    void handleToggleStatus(BuildContext context) async {
      if (post != null && !isToggling.value) {
        final currentPost = post!;
        final isLocked = currentPost.status == PostStatus.locked.value;
        final actionText = isLocked ? 'mở khóa' : 'khóa';

        final confirmed = await context.showConfirmDialog(
          title: 'Xác nhận',
          content: 'Bạn có chắc chắn muốn $actionText danh sách quan tâm?',
          confirmText: 'Xác nhận',
          cancelText: 'Hủy',
        );

        if (confirmed == true && context.mounted) {
          isToggling.value = true;

          await ref
              .read(postProvider.notifier)
              .togglePostStatus(currentPost.id!, currentPost.status!);

          if (context.mounted) {
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(slug: currentPost.slug);
          }
        }
      }
    }

    void handleRepost(BuildContext context, bool canRepostValue) async {
      if (post != null && !isReposting.value) {
        final currentPost = post!;

        if (!canRepostValue) {
          final now = DateTime.now();
          final createdAt = currentPost.createdAt!;
          final difference = now.difference(createdAt);
          final remainingDays = 7 - difference.inDays;

          context.showInfoDialog(
            title: 'Thông báo',
            content:
                'Chỉ có thể ghim sau 1 tuần từ lần đăng cuối! Còn lại $remainingDays ngày.',
            icon: Icons.info_outline,
          );
          return;
        }

        final confirmed = await context.showConfirmDialog(
          title: 'Xác nhận ghim',
          content: 'Bạn có chắc chắn muốn ghim bài đăng này?',
          confirmText: 'Ghim',
          cancelText: 'Hủy',
        );

        if (confirmed == true && context.mounted) {
          isReposting.value = true;

          await ref
              .read(postProvider.notifier)
              .repostPost(currentPost.id!, currentPost.createdAt!);

          if (context.mounted) {
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(slug: currentPost.slug);
          }
        }
      }
    }

    void handleDeletePost(BuildContext context) async {
      if (post != null && !isDeleting.value) {
        final currentPost = post!;

        final confirmed = await context.showConfirmDialog(
          title: 'Xác nhận xóa bài đăng',
          content:
              'Bạn có chắc chắn muốn xóa bài đăng này?\n\n'
              '⚠️ Hành động này không thể hoàn tác!',
          confirmText: 'Xóa bài đăng',
          cancelText: 'Hủy',
        );

        if (confirmed == true && context.mounted) {
          isDeleting.value = true;

          await ref.read(postProvider.notifier).deletePost(currentPost.id!);
        }
      }
    }

    // Nếu không phải chủ sở hữu, hiển thị UI cũ
    if (!isPostOwner) {
      return Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Nút quan tâm
              Expanded(
                child: _buildInterestButton(
                  isTablet,
                  theme,
                  colorScheme,
                  interestState,
                  isCampaignOngoing(),
                  getInterestButtonText,
                ),
              ),

              // Nút nhắn tin (chỉ hiển thị khi đã quan tâm)
              if (userInterested && interestId != null) ...[
                SizedBox(width: isTablet ? 16 : 12),
                _buildChatButton(isTablet, theme, colorScheme),
              ],
            ],
          ),
        ),
      );
    }

    // UI cho chủ sở hữu bài đăng
    if (post == null) {
      return const SizedBox.shrink();
    }

    final postStatus = post!.status;
    final createdAt = post!.createdAt;
    final canRepostValue = canRepost(createdAt!);
    final isPending = postStatus == PostStatus.pending.value;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nếu là pending, chỉ hiển thị nút xóa
            if (isPending) ...[
              _buildDeleteButton(
                context,
                isTablet,
                colorScheme,
                isDeleting.value,
                handleDeletePost,
              ),
            ] else ...[
              // Hàng đầu tiên: Khóa/Mở khóa và Đăng lại
              Row(
                children: [
                  // Nút khóa/mở khóa danh sách quan tâm
                  Expanded(
                    child: _buildToggleStatusButton(
                      context,
                      isTablet,
                      colorScheme,
                      postStatus!,
                      isToggling.value,
                      handleToggleStatus,
                    ),
                  ),

                  // Nút ghim (hiển thị khi status = 3 hoặc 4)
                  if (postStatus == PostStatus.approved.value ||
                      postStatus == PostStatus.locked.value) ...[
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: _buildRepostButton(
                        context,
                        isTablet,
                        colorScheme,
                        canRepostValue,
                        isReposting.value,
                        handleRepost,
                      ),
                    ),
                  ],
                ],
              ),

              // Hàng thứ hai: Nút xóa bài đăng
              SizedBox(height: isTablet ? 12 : 8),
              _buildDeleteButton(
                context,
                isTablet,
                colorScheme,
                isDeleting.value,
                handleDeletePost,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Cập nhật các build methods để nhận parameters
  Widget _buildInterestButton(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic interestState,
    bool canInterest,
    String Function(bool, bool) getInterestButtonText,
  ) {
    final isDisabled = !canInterest || interestState.isLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : onInterest,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor:
            canInterest
                ? (userInterested ? Colors.red : colorScheme.primary)
                : Colors.grey.shade400,
        disabledBackgroundColor: Colors.grey.shade400,
        elevation: userInterested && canInterest ? 2 : 1,
        shadowColor:
            userInterested && canInterest ? Colors.red.withOpacity(0.3) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (interestState.isLoading && canInterest)
            SizedBox(
              width: isTablet ? 16 : 14,
              height: isTablet ? 16 : 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(
              canInterest
                  ? (userInterested ? Icons.favorite : Icons.favorite_border)
                  : Icons.block,
              size: isTablet ? 18 : 16,
              color: Colors.white,
            ),
          SizedBox(width: isTablet ? 8 : 6),
          Flexible(
            child: Text(
              getInterestButtonText(interestState.isLoading, canInterest),
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ElevatedButton(
      onPressed: () => onChatTap(interestId!),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 14 : 12,
        ),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: isTablet ? 18 : 16,
            color: Colors.white,
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            'Nhắn tin',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleStatusButton(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
    int postStatus,
    bool isToggling,
    Function(BuildContext) handleToggleStatus,
  ) {
    final isLocked = postStatus == PostStatus.locked.value;
    final buttonText = isLocked ? 'Mở khóa quan tâm' : 'Khóa quan tâm';
    final buttonColor = isLocked ? Colors.green : Colors.orange;
    final buttonIcon = isLocked ? Icons.lock_open : Icons.lock;

    return ElevatedButton(
      onPressed: isToggling ? null : () => handleToggleStatus(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor: buttonColor,
        disabledBackgroundColor: buttonColor.withOpacity(0.6),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isToggling)
            SizedBox(
              width: isTablet ? 16 : 14,
              height: isTablet ? 16 : 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(buttonIcon, size: isTablet ? 18 : 16, color: Colors.white),
          SizedBox(width: isTablet ? 8 : 6),
          Flexible(
            child: Text(
              isToggling ? 'Đang xử lý...' : buttonText,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildRepostButton(
  BuildContext context,
  bool isTablet,
  ColorScheme colorScheme,
  bool canRepost,
  bool isReposting,
  Function(BuildContext, bool) handleRepost,
) {
  return ElevatedButton(
    onPressed: isReposting ? null : () => handleRepost(context, canRepost),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
      backgroundColor: colorScheme.primary,
      disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
      elevation: 1,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isReposting)
          SizedBox(
            width: isTablet ? 16 : 14,
            height: isTablet ? 16 : 14,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          Icon(Icons.refresh, size: isTablet ? 18 : 16, color: Colors.white),
        SizedBox(width: isTablet ? 8 : 6),
        Flexible(
          child: Text(
            isReposting ? 'Đang xử lý...' : 'Ghim',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDeleteButton(
  BuildContext context,
  bool isTablet,
  ColorScheme colorScheme,
  bool isDeleting,
  Function(BuildContext) handleDeletePost,
) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isDeleting ? null : () => handleDeletePost(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor: Colors.red,
        disabledBackgroundColor: Colors.red.withOpacity(0.6),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDeleting)
            SizedBox(
              width: isTablet ? 16 : 14,
              height: isTablet ? 16 : 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(
              Icons.delete_outline,
              size: isTablet ? 18 : 16,
              color: Colors.white,
            ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            isDeleting ? 'Đang xóa...' : 'Xóa bài đăng',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
