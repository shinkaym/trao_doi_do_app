import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';
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
    required this.postSlug, // Thêm required parameter
  }) : super(key: key);

  @override
  ConsumerState<PostBottomActionBar> createState() =>
      _PostBottomActionBarState();
}

class _PostBottomActionBarState extends ConsumerState<PostBottomActionBar> {
  bool _isToggling = false; // Trạng thái loading riêng cho toggle
  bool _isReposting = false; // Trạng thái loading riêng cho repost

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
          });
        }

        // Handle success message
        if (current.successMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(current.successMessage!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Refresh post detail để cập nhật UI
            Future.microtask(() {
              if (mounted) {
                ref
                    .read(postDetailProvider.notifier)
                    .getPostDetail(widget.postSlug);
              }
            });
          }
        }

        // Handle error
        if (current.failure != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(current.failure!.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
    if (widget.post == null) return const SizedBox.shrink();

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
        child: Row(
          children: [
            // Nút khóa/mở khóa danh sách quan tâm
            Expanded(
              child: _buildToggleStatusButton(
                isTablet,
                colorScheme,
                postStatus!,
              ),
            ),

            // Nút đăng lại (hiển thị khi status = 3 hoặc 4)
            if (postStatus == 3 || postStatus == 4) ...[
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
      ),
    );
  }

  Widget _buildInterestButton(
    bool isTablet,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic interestState,
  ) {
    return ElevatedButton(
      onPressed: interestState.isLoading ? null : widget.onInterest,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
        backgroundColor:
            widget.userInterested ? Colors.red : colorScheme.primary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
        elevation: widget.userInterested ? 2 : 1,
        shadowColor: widget.userInterested ? Colors.red.withOpacity(0.3) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (interestState.isLoading)
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
              widget.userInterested ? Icons.favorite : Icons.favorite_border,
              size: isTablet ? 18 : 16,
              color: Colors.white,
            ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            _getInterestButtonText(interestState.isLoading),
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
    final isLocked = postStatus == 4;
    final buttonText = isLocked ? 'Mở khóa quan tâm' : 'Khóa quan tâm';
    final buttonColor = isLocked ? Colors.green : Colors.orange;
    final buttonIcon = isLocked ? Icons.lock_open : Icons.lock;

    return ElevatedButton(
      onPressed: _isToggling ? null : _handleToggleStatus,
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
              _isReposting ? 'Đang xử lý...' : 'Đăng lại',
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

  String _getInterestButtonText(bool isLoading) {
    if (isLoading) return 'Đang xử lý...';
    if (widget.userInterested) return 'Đã quan tâm (${widget.interestCount})';
    return 'Quan tâm (${widget.interestCount})';
  }

  bool _canRepost(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays >= 7;
  }

  void _handleToggleStatus() {
    if (widget.post != null && !_isToggling) {
      setState(() {
        _isToggling = true;
      });

      ref
          .read(postProvider.notifier)
          .togglePostStatus(widget.post!.id!, widget.post!.status!);
    }
  }

  void _handleRepost(BuildContext context, bool canRepost) {
    if (widget.post != null && !_isReposting) {
      // Kiểm tra nếu chưa đủ 1 tuần
      if (!canRepost) {
        final now = DateTime.now();
        final createdAt = widget.post!.createdAt!;
        final difference = now.difference(createdAt);
        final remainingDays = 7 - difference.inDays;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chỉ có thể đăng lại sau 1 tuần từ lần đăng cuối! Còn lại $remainingDays ngày.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _isReposting = true;
      });

      // Nếu đủ điều kiện thì gọi repost
      ref
          .read(postProvider.notifier)
          .repostPost(widget.post!.id!, widget.post!.createdAt!);
    }
  }
}
