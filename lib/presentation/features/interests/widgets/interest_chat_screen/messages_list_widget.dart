import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/message.dart';
import 'package:trao_doi_do_app/presentation/features/interests/widgets/interest_chat_screen/message_bubble.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/messages_provider.dart';

class MessagesListWidget extends StatefulWidget {
  final MessagesListState messagesState;
  final MessagesListNotifier messagesNotifier;
  final ScrollController scrollController;
  final AuthState authState;
  final String displayName;
  final String displayAvatar;
  final bool isTablet;
  final VoidCallback onPostTap;

  const MessagesListWidget({
    super.key,
    required this.messagesState,
    required this.messagesNotifier,
    required this.scrollController,
    required this.authState,
    required this.displayName,
    required this.displayAvatar,
    required this.isTablet,
    required this.onPostTap,
  });

  @override
  State<MessagesListWidget> createState() => _MessagesListWidgetState();
}

class _MessagesListWidgetState extends State<MessagesListWidget> {
  bool _showScrollDownButton = false;
  int _previousMessageCount = 0;
  double _scrollPositionBeforeLoad = 0;
  final GlobalKey _sliverListKey = GlobalKey();

  // Improved scroll position tracking
  String? _anchorMessageId;
  double _anchorOffset = 0;
  bool _isLoadingMore = false;

  // Performance optimization
  final Map<String, double> _messageHeights = {};
  static const int _maxCachedHeights = 50;
  static const double _defaultMessageHeight = 60.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _previousMessageCount = widget.messagesState.messages.length;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(MessagesListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentMessageCount = widget.messagesState.messages.length;
    final wasLoadingMore = oldWidget.messagesState.isLoadingMore;
    final isLoadingMore = widget.messagesState.isLoadingMore;

    // Start loading more - capture current state
    if (!wasLoadingMore && isLoadingMore) {
      _captureScrollState();
      _isLoadingMore = true;
    }

    // Finished loading more - restore scroll position
    if (wasLoadingMore &&
        !isLoadingMore &&
        currentMessageCount > _previousMessageCount) {
      _isLoadingMore = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    }

    _previousMessageCount = currentMessageCount;
  }

  void _captureScrollState() {
    if (!widget.scrollController.hasClients) return;

    try {
      final scrollOffset = widget.scrollController.offset;
      final messages = widget.messagesState.messages;
      if (messages.isEmpty) return;

      // Tìm message gần nhất với viewport center
      final viewportHeight = widget.scrollController.position.viewportDimension;
      final centerOffset = scrollOffset + (viewportHeight / 2);

      // Tính index chính xác hơn
      double accumulatedHeight = 0;
      int targetIndex = 0;

      for (int i = 0; i < messages.length; i++) {
        final messageHeight =
            _messageHeights[messages[i].id.toString()] ??
            _getAverageMessageHeight();
        if (accumulatedHeight + messageHeight > centerOffset) {
          targetIndex = i;
          _anchorOffset = centerOffset - accumulatedHeight;
          break;
        }
        accumulatedHeight += messageHeight;
      }

      _anchorMessageId = messages[targetIndex].id.toString();
      _scrollPositionBeforeLoad = scrollOffset;
    } catch (e) {
      _scrollPositionBeforeLoad = widget.scrollController.offset;
      _anchorMessageId = null;
    }
  }

  void _restoreScrollPosition() {
    if (!widget.scrollController.hasClients) return;

    try {
      // Method 1: Try to find anchor message and restore relative position
      if (_anchorMessageId != null && _restoreByAnchor()) {
        return;
      }

      // Method 2: Use improved height estimation
      _restoreByHeightEstimation();
    } catch (e) {
      // Fallback: Simple position restoration
      _restoreSimplePosition();
    }
  }

  bool _restoreByAnchor() {
    if (_anchorMessageId == null) return false;

    final messages = widget.messagesState.messages;
    final anchorIndex = messages.indexWhere(
      (m) => m.id.toString() == _anchorMessageId,
    );

    if (anchorIndex == -1) return false;

    // Tính toán position chính xác dựa trên height thực tế
    double targetPosition = 0;

    for (int i = 0; i < anchorIndex; i++) {
      final messageId = messages[i].id.toString();
      final height = _messageHeights[messageId] ?? _getAverageMessageHeight();
      targetPosition += height;
    }

    targetPosition += _anchorOffset;

    // Scroll ngay lập tức để tránh hiệu ứng nhảy
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    widget.scrollController.jumpTo(targetPosition.clamp(0.0, maxScroll));

    return true;
  }

  void _restoreByHeightEstimation() {
    final newMessagesCount =
        widget.messagesState.messages.length - _previousMessageCount;

    // Sử dụng height trung bình thực tế từ cache
    double totalNewHeight = 0;
    final messages = widget.messagesState.messages;

    // Tính height của messages mới (ở đầu danh sách)
    for (int i = 0; i < newMessagesCount.clamp(0, messages.length); i++) {
      final messageId = messages[i].id.toString();
      totalNewHeight +=
          _messageHeights[messageId] ?? _getAverageMessageHeight();
    }

    final targetPosition = _scrollPositionBeforeLoad + totalNewHeight;
    final maxScroll = widget.scrollController.position.maxScrollExtent;

    // Dùng jumpTo thay vì animateTo để tránh animation giật
    widget.scrollController.jumpTo(targetPosition.clamp(0.0, maxScroll));
  }

  void _restoreSimplePosition() {
    final newMessagesCount =
        widget.messagesState.messages.length - _previousMessageCount;
    final estimatedHeight = newMessagesCount * _defaultMessageHeight;
    final targetPosition = _scrollPositionBeforeLoad + estimatedHeight;
    final maxScroll = widget.scrollController.position.maxScrollExtent;

    widget.scrollController.jumpTo(targetPosition.clamp(0.0, maxScroll));
  }

  double _getAverageMessageHeight() {
    if (_messageHeights.isEmpty) {
      return widget.isTablet ? 70.0 : _defaultMessageHeight;
    }

    // Use median to avoid outliers affecting the calculation
    final heights = _messageHeights.values.toList()..sort();
    if (heights.length % 2 == 0) {
      return (heights[heights.length ~/ 2 - 1] + heights[heights.length ~/ 2]) /
          2;
    } else {
      return heights[heights.length ~/ 2];
    }
  }

  void _onScroll() {
    if (_isLoadingMore || !mounted) return;

    final position = widget.scrollController.position;
    if (!position.hasPixels) return;

    final isNearTop = position.pixels <= 100;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 100;

    // Trigger load more when near top - với debounce
    if (isNearTop &&
        !widget.messagesState.isLoadingMore &&
        !widget.messagesState.isLoading) {
      widget.messagesNotifier.loadMore();
    }

    // Show/hide scroll down button - chỉ setState khi cần thiết
    final shouldShowButton = !isAtBottom;
    if (shouldShowButton != _showScrollDownButton) {
      setState(() {
        _showScrollDownButton = shouldShowButton;
      });
    }
  }

  void _scrollToBottom() {
    if (!widget.scrollController.hasClients) return;

    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onMessageHeightCalculated(String messageId, double height) {
    // Chỉ update nếu height thay đổi đáng kể
    final existingHeight = _messageHeights[messageId];
    if (existingHeight != null && (height - existingHeight).abs() < 5) {
      return;
    }

    _messageHeights[messageId] = height;

    // Tối ưu cache management
    if (_messageHeights.length > _maxCachedHeights) {
      // Xóa những message cũ nhất thay vì xóa theo thứ tự
      final sortedEntries =
          _messageHeights.entries.toList()..sort(
            (a, b) => widget.messagesState.messages
                .indexWhere((m) => m.id.toString() == a.key)
                .compareTo(
                  widget.messagesState.messages.indexWhere(
                    (m) => m.id.toString() == b.key,
                  ),
                ),
          );

      final keysToRemove = sortedEntries
          .take(_messageHeights.length - _maxCachedHeights)
          .map((e) => e.key);

      for (final key in keysToRemove) {
        _messageHeights.remove(key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messagesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => widget.messagesNotifier.refresh(),
          child: CustomScrollView(
            controller: widget.scrollController,
            reverse: false, // Keep normal scroll direction
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Loading indicator at top
              if (widget.messagesState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),

              // Messages list
              SliverList(
                key: _sliverListKey,
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= widget.messagesState.messages.length) {
                    return const SizedBox.shrink();
                  }

                  final message = widget.messagesState.messages[index];
                  final isCurrentUser =
                      message.senderID == widget.authState.user!.id;

                  // Determine if avatar should be shown
                  final showAvatar =
                      index == widget.messagesState.messages.length - 1 ||
                      (index < widget.messagesState.messages.length - 1 &&
                          widget.messagesState.messages[index + 1].senderID !=
                              message.senderID);

                  final messageKey = message.id.toString();

                  return MeasuredMessageBubble(
                    key: ValueKey(messageKey),
                    messageId: messageKey,
                    message: message,
                    isCurrentUser: isCurrentUser,
                    showAvatar: showAvatar,
                    isTablet: widget.isTablet,
                    otherUserName: widget.displayName,
                    otherUserAvatar: widget.displayAvatar,
                    currentUserName: widget.authState.user!.fullName,
                    currentUserAvatar: widget.authState.user!.avatar,
                    onPostTap: widget.onPostTap,
                    messages: widget.messagesState.messages,
                    messageIndex: index,
                    onHeightCalculated: _onMessageHeightCalculated,
                  );
                }, childCount: widget.messagesState.messages.length),
              ),

              // Bottom spacer to ensure proper scrolling
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),

        // Scroll to bottom button
        if (_showScrollDownButton)
          Positioned(
            bottom: widget.isTablet ? 24 : 16,
            right: widget.isTablet ? 24 : 16,
            child: AnimatedOpacity(
              opacity: _showScrollDownButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 4,
                child: const Icon(Icons.keyboard_arrow_down, size: 20),
              ),
            ),
          ),
      ],
    );
  }
}

// Optimized message bubble wrapper with better height measurement
class MeasuredMessageBubble extends StatefulWidget {
  final String messageId;
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final bool isTablet;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserName;
  final String currentUserAvatar;
  final VoidCallback onPostTap;
  final List<Message> messages;
  final int messageIndex;
  final Function(String messageId, double height) onHeightCalculated;

  const MeasuredMessageBubble({
    super.key,
    required this.messageId,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.isTablet,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.onPostTap,
    required this.messages,
    required this.messageIndex,
    required this.onHeightCalculated,
  });

  @override
  State<MeasuredMessageBubble> createState() => _MeasuredMessageBubbleState();
}

class _MeasuredMessageBubbleState extends State<MeasuredMessageBubble> {
  final GlobalKey _containerKey = GlobalKey();
  bool _hasReportedHeight = false;
  double? _lastReportedHeight;

  @override
  void initState() {
    super.initState();
    // Đo height sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
  }

  @override
  void didUpdateWidget(MeasuredMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Chỉ đo lại height khi nội dung thay đổi
    if (oldWidget.message.message != widget.message.message ||
        oldWidget.isTablet != widget.isTablet ||
        oldWidget.showAvatar != widget.showAvatar) {
      _hasReportedHeight = false;
      _lastReportedHeight = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
    }
  }

  void _measureHeight() {
    if (!mounted) return;

    final renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox?.hasSize == true) {
      final height = renderBox!.size.height;

      // Chỉ báo cáo nếu height thay đổi đáng kể
      if (_lastReportedHeight == null ||
          (_lastReportedHeight! - height).abs() > 2) {
        widget.onHeightCalculated(widget.messageId, height);
        _hasReportedHeight = true;
        _lastReportedHeight = height;
      }
    } else {
      // Retry sau 100ms nếu chưa có size
      if (!_hasReportedHeight) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _measureHeight();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // Tránh repaint không cần thiết
      child: Container(
        key: _containerKey,
        child: MessageBubble(
          message: widget.message,
          isCurrentUser: widget.isCurrentUser,
          showAvatar: widget.showAvatar,
          isTablet: widget.isTablet,
          otherUserName: widget.otherUserName,
          otherUserAvatar: widget.otherUserAvatar,
          currentUserName: widget.currentUserName,
          currentUserAvatar: widget.currentUserAvatar,
          onPostTap: widget.onPostTap,
          messages: widget.messages,
          messageIndex: widget.messageIndex,
        ),
      ),
    );
  }
}
