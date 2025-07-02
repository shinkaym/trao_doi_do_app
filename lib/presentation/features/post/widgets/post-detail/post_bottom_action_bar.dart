import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';

class PostBottomActionBar extends ConsumerStatefulWidget {
  final bool userInterested;
  final int interestCount;
  final VoidCallback onInterest;
  final VoidCallback onShare;
  final int? interestId;
  final Function(int) onChatTap;
  final bool isPostOwner;
  final PostDetail? post;
  final String postSlug;

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
    required this.postSlug,
  }) : super(key: key);

  @override
  ConsumerState<PostBottomActionBar> createState() =>
      _PostBottomActionBarState();
}

class _PostBottomActionBarState extends ConsumerState<PostBottomActionBar> {
  bool _isToggling = false;
  bool _isReposting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final interestState = ref.watch(interestProvider);

    // Listen to postState changes để xử lý success/error
    ref.listen<PostState>(postProvider, (previous, current) {
      if (previous?.isLoading == true && current.isLoading == false) {
        // Reset loading states
        if (mounted) {
          setState(() {
            _isToggling = false;
            _isReposting = false;
            _isDeleting = false;
          });
        }

        // Handle success message for delete action
        if (current.successMessage != null &&
            current.successMessage!.contains('Xóa bài đăng thành công')) {
          if (mounted) {
            context.showSuccessSnackBar(current.successMessage!);
            // Navigate back after successful deletion
            context.pop();
          }
        }
      }
    });

    // Nếu không phải chủ sở hữu, hiển thị UI cũ
    if (!widget.isPostOwner) {
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
                ),
              ),

              // Nút nhắn tin (chỉ hiển thị khi đã quan tâm)
              if (widget.userInterested && widget.interestId != null) ...[
                SizedBox(width: isTablet ? 16 : 12),
                _buildChatButton(isTablet, theme, colorScheme),
              ],
            ],
          ),
        ),
      );
    }

    // UI cho chủ sở hữu bài đăng
    if (widget.post == null ||
        widget.post!.status == PostStatus.pending.value) {
      // Ẩn action bar nếu đang chờ duyệt
      return const SizedBox.shrink();
    }

    final postStatus = widget.post!.status;
    final createdAt = widget.post!.createdAt;
    final canRepost = _canRepost(createdAt!);

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
            // Hàng đầu tiên: Khóa/Mở khóa và Đăng lại
            Row(
              children: [
                // Nút khóa/mở khóa danh sách quan tâm
                Expanded(
                  child: _buildToggleStatusButton(
                    isTablet,
                    colorScheme,
                    postStatus!,
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
                      canRepost,
                    ),
                  ),
                ],
              ],
            ),

            // Hàng thứ hai: Nút xóa bài đăng
            SizedBox(height: isTablet ? 12 : 8),
            _buildDeleteButton(context, isTablet, colorScheme),
          ],
        ),
      ),
    );
  }

  /// Kiểm tra xem chiến dịch có đang diễn ra không
  bool _isCampaignOngoing() {
    if (widget.post == null) return true;

    final postType = PostType.values.firstWhere(
      (type) => type.value == widget.post!.type,
      orElse: () => PostType.all,
    );

    // Nếu không phải bài đăng chiến dịch, luôn cho phép quan tâm
    if (postType != PostType.campaign) return true;

    try {
      final campaignInfo = CampaignInfo.fromJson(jsonDecode(widget.post!.info));
      final now = DateTime.now();

      DateTime? startDate;
      DateTime? endDate;

      if (campaignInfo.startDate.isNotEmpty) {
        startDate = DateTime.parse(campaignInfo.startDate);
      }

      if (campaignInfo.endDate.isNotEmpty) {
        endDate = DateTime.parse(campaignInfo.endDate);
      }

      // Nếu có cả start và end date
      if (startDate != null && endDate != null) {
        return now.isAfter(startDate) && now.isBefore(endDate);
      }
      // Nếu chỉ có start date
      else if (startDate != null) {
        return now.isAfter(startDate);
      }
      // Nếu chỉ có end date
      else if (endDate != null) {
        return now.isBefore(endDate);
      }

      // Nếu không có ngày nào được thiết lập, cho phép quan tâm
      return true;
    } catch (e) {
      // Nếu có lỗi parse, cho phép quan tâm
      return true;
    }
  }

  Widget _buildInterestButton(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic interestState,
  ) {
    final canInterest = _isCampaignOngoing();
    final isDisabled = !canInterest || interestState.isLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : widget.onInterest,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor:
            canInterest
                ? (widget.userInterested ? Colors.red : colorScheme.primary)
                : Colors.grey.shade400,
        disabledBackgroundColor: Colors.grey.shade400,
        elevation: widget.userInterested && canInterest ? 2 : 1,
        shadowColor:
            widget.userInterested && canInterest
                ? Colors.red.withOpacity(0.3)
                : null,
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
                  ? (widget.userInterested
                      ? Icons.favorite
                      : Icons.favorite_border)
                  : Icons.block,
              size: isTablet ? 18 : 16,
              color: Colors.white,
            ),
          SizedBox(width: isTablet ? 8 : 6),
          Flexible(
            child: Text(
              _getInterestButtonText(interestState.isLoading, canInterest),
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
      onPressed: () => widget.onChatTap(widget.interestId!),
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
    bool isTablet,
    ColorScheme colorScheme,
    int postStatus,
  ) {
    final isLocked = postStatus == PostStatus.locked.value;
    final buttonText = isLocked ? 'Mở khóa quan tâm' : 'Khóa quan tâm';
    final buttonColor = isLocked ? Colors.green : Colors.orange;
    final buttonIcon = isLocked ? Icons.lock_open : Icons.lock;

    return ElevatedButton(
      onPressed: _isToggling ? null : () => _handleToggleStatus(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor: buttonColor,
        disabledBackgroundColor: buttonColor.withOpacity(0.6),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isToggling)
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
              _isToggling ? 'Đang xử lý...' : buttonText,
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

  Widget _buildRepostButton(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
    bool canRepost,
  ) {
    return ElevatedButton(
      onPressed: _isReposting ? null : () => _handleRepost(context, canRepost),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isReposting)
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
              _isReposting ? 'Đang xử lý...' : 'Ghim',
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
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isDeleting ? null : () => _handleDeletePost(context),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
          backgroundColor: Colors.red,
          disabledBackgroundColor: Colors.red.withOpacity(0.6),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDeleting)
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
              _isDeleting ? 'Đang xóa...' : 'Xóa bài đăng',
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

  String _getInterestButtonText(bool isLoading, bool canInterest) {
    if (!canInterest) return 'Không thể quan tâm';
    if (isLoading) return 'Đang xử lý...';
    if (widget.userInterested) return 'Đã quan tâm (${widget.interestCount})';
    return 'Quan tâm (${widget.interestCount})';
  }

  bool _canRepost(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays >= 7;
  }

  void _handleToggleStatus(BuildContext context) async {
    if (widget.post != null && !_isToggling) {
      final post = widget.post!;
      final isLocked = post.status == PostStatus.locked.value;
      final actionText = isLocked ? 'mở khóa' : 'khóa';

      final confirmed = await context.showConfirmDialog(
        title: 'Xác nhận',
        content: 'Bạn có chắc chắn muốn $actionText danh sách quan tâm?',
        confirmText: 'Xác nhận',
        cancelText: 'Hủy',
      );

      if (confirmed == true && mounted) {
        try {
          context.showLoadingDialog(message: 'Đang xử lý...');

          setState(() {
            _isToggling = true;
          });

          await ref
              .read(postProvider.notifier)
              .togglePostStatus(post.id!, post.status!);

          if (mounted) {
            context.dismissDialog();
            context.showSuccessSnackBar('Đã $actionText bài đăng thành công!');

            // Refresh post detail
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(widget.postSlug);
          }
        } catch (e) {
          if (mounted) {
            context.dismissDialog();
            context.showErrorSnackBar(
              'Có lỗi xảy ra khi $actionText bài đăng!',
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isToggling = false;
            });
          }
        }
      }
    }
  }

  void _handleRepost(BuildContext context, bool canRepost) async {
    if (widget.post != null && !_isReposting) {
      final post = widget.post!;

      // Kiểm tra nếu chưa đủ 1 tuần
      if (!canRepost) {
        final now = DateTime.now();
        final createdAt = post.createdAt!;
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

      // Hiển thị dialog xác nhận
      final confirmed = await context.showConfirmDialog(
        title: 'Xác nhận ghim',
        content: 'Bạn có chắc chắn muốn ghim bài đăng này?',
        confirmText: 'Ghim',
        cancelText: 'Hủy',
      );

      if (confirmed == true && mounted) {
        try {
          context.showLoadingDialog(message: 'Đang ghim...');

          setState(() {
            _isReposting = true;
          });

          await ref
              .read(postProvider.notifier)
              .repostPost(post.id!, post.createdAt!);

          if (mounted) {
            context.dismissDialog();
            context.showSuccessSnackBar('Đã ghim bài đăng thành công!');

            // Refresh post detail
            ref
                .read(postDetailProvider.notifier)
                .getPostDetail(widget.postSlug);
          }
        } catch (e) {
          if (mounted) {
            context.dismissDialog();
            context.showErrorSnackBar('Có lỗi xảy ra khi ghim bài đăng!');
          }
        } finally {
          if (mounted) {
            setState(() {
              _isReposting = false;
            });
          }
        }
      }
    }
  }

  void _handleDeletePost(BuildContext context) async {
    if (widget.post != null && !_isDeleting) {
      final post = widget.post!;

      // Hiển thị dialog xác nhận xóa với cảnh báo nghiêm trọng
      final confirmed = await context.showConfirmDialog(
        title: 'Xác nhận xóa bài đăng',
        content:
            'Bạn có chắc chắn muốn xóa bài đăng này?\n\n'
            '⚠️ Hành động này không thể hoàn tác!\n'
            '• Tất cả thông tin bài đăng sẽ bị xóa vĩnh viễn\n'
            '• Danh sách quan tâm sẽ bị xóa\n'
            '• Các cuộc trò chuyện liên quan sẽ bị ảnh hưởng',
        confirmText: 'Xóa bài đăng',
        cancelText: 'Hủy',
        // isDestructive: true,
      );

      if (confirmed == true && mounted) {
        try {
          context.showLoadingDialog(message: 'Đang xóa bài đăng...');

          setState(() {
            _isDeleting = true;
          });

          await ref.read(postProvider.notifier).deletePost(post.id!);

          // Success handling is done in the listener above
        } catch (e) {
          if (mounted) {
            context.dismissDialog();
            context.showErrorSnackBar('Có lỗi xảy ra khi xóa bài đăng!');

            setState(() {
              _isDeleting = false;
            });
          }
        }
      }
    }
  }
}
