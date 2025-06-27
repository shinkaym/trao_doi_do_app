import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/time_utils.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class PostInfoHeader extends StatelessWidget {
  final List<Transaction> transactions;
  final InterestPost post;
  final bool isPostOwner;
  final bool isLoadingTransactions;
  final bool isTablet;
  final VoidCallback onPostTap;
  final VoidCallback onTransactionTap;
  final VoidCallback onRefreshTransactions;

  const PostInfoHeader({
    super.key,
    required this.transactions,
    required this.post,
    required this.isPostOwner,
    required this.isLoadingTransactions,
    required this.isTablet,
    required this.onPostTap,
    required this.onTransactionTap,
    required this.onRefreshTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Get post type information
    final postTypeEnum = PostType.fromValue(post.type);
    final latestTransaction =
        transactions.isNotEmpty ? transactions.first : null;

    // Check if post type don't show transaction section
    final shouldShowTransaction =
        post.type != PostType.campaign && post.type != PostType.freePost;

    return Container(
      margin: EdgeInsets.all(isTablet ? 16 : 12),
      child: Column(
        children: [
          // Post info
          _buildPostInfoCard(theme, colorScheme, postTypeEnum),

          // Latest transaction info (only if not freePost)
          if (shouldShowTransaction) ...[
            SizedBox(height: isTablet ? 8 : 6),
            _buildTransactionInfoCard(theme, colorScheme, latestTransaction),
          ],
        ],
      ),
    );
  }

  Widget _buildPostInfoCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PostType postTypeEnum,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onPostTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              postTypeEnum.icon,
              size: isTablet ? 24 : 20,
              color: postTypeEnum.color,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Về bài đăng: ${postTypeEnum.label}',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    post.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 14 : 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 16 : 14,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfoCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Transaction? latestTransaction,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: isLoadingTransactions ? null : onTransactionTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            _buildTransactionIcon(theme, colorScheme, latestTransaction),

            SizedBox(width: isTablet ? 12 : 8),

            Expanded(child: _buildTransactionInfo(theme, latestTransaction)),

            // Refresh button
            if (!isLoadingTransactions)
              IconButton(
                onPressed: onRefreshTransactions,
                icon: Icon(
                  Icons.refresh,
                  size: isTablet ? 18 : 16,
                  color: theme.hintColor,
                ),
                padding: EdgeInsets.all(isTablet ? 8 : 4),
                constraints: BoxConstraints(
                  minWidth: isTablet ? 32 : 24,
                  minHeight: isTablet ? 32 : 24,
                ),
              ),

            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 16 : 14,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(
    ThemeData theme,
    ColorScheme colorScheme,
    Transaction? latestTransaction,
  ) {
    if (isLoadingTransactions) {
      return SizedBox(
        width: isTablet ? 20 : 18,
        height: isTablet ? 20 : 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.secondary,
        ),
      );
    } else if (latestTransaction != null) {
      return Icon(
        TransactionStatus.fromValue(latestTransaction.status).icon,
        size: isTablet ? 20 : 18,
        color: TransactionStatus.fromValue(latestTransaction.status).color,
      );
    } else {
      return Icon(
        Icons.history,
        size: isTablet ? 20 : 18,
        color: theme.hintColor,
      );
    }
  }

  Widget _buildTransactionInfo(
    ThemeData theme,
    Transaction? latestTransaction,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLoadingTransactions
              ? 'Đang tải giao dịch...'
              : latestTransaction != null
              ? 'Yêu cầu mới nhất'
              : 'Chưa có giao dịch',
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        if (latestTransaction != null) ...[
          SizedBox(height: isTablet ? 4 : 2),
          Row(
            children: [
              Text(
                TimeUtils.formatTimeAgo(
                  DateTime.parse(latestTransaction.createdAt),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: TransactionStatus.fromValue(
                    latestTransaction.status,
                  ).color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  TransactionStatus.fromValue(
                    latestTransaction.status,
                  ).getLabel(isPostOwner: isPostOwner),
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    color:
                        TransactionStatus.fromValue(
                          latestTransaction.status,
                        ).color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
