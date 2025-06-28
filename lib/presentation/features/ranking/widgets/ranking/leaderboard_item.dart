import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/user_avatar.dart';

class LeaderboardItem extends StatelessWidget {
  final UserRank user;
  final int displayRank;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const LeaderboardItem({
    super.key,
    required this.user,
    required this.displayRank,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isTopFive = displayRank <= 5;
    final totalGoodDeeds = user.goodDeeds.fold(
      0,
      (sum, deed) => sum + deed.goodDeedCount,
    );

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color:
            isTopFive
                ? colorScheme.primaryContainer.withOpacity(0.1)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isTopFive
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
          width: isTopFive ? 2 : 1,
        ),
        boxShadow:
            isTopFive
                ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Row(
        children: [
          // Rank Badge
          RankBadge(
            rank: displayRank,
            isTablet: isTablet,
            colorScheme: colorScheme,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // Avatar
          Container(
            width: isTablet ? 50 : 45,
            height: isTablet ? 50 : 45,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: UserAvatar(
                avatarBase64: user.userAvatar,
                size: isTablet ? 45 : 40,
                isTablet: isTablet,
                iconColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.major.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 2 : 1),
                  Text(
                    user.major,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: isTablet ? 6 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: isTablet ? 14 : 12,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(width: isTablet ? 4 : 3),
                    Expanded(
                      child: Text(
                        '$totalGoodDeeds việc tốt',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: isTablet ? 16 : 14,
                  color: Colors.amber.shade600,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  '${user.goodPoint}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RankBadge extends StatelessWidget {
  final int rank;
  final bool isTablet;
  final ColorScheme colorScheme;

  const RankBadge({
    super.key,
    required this.rank,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isTopFive = rank <= 5;

    return Container(
      width: isTablet ? 50 : 45,
      height: isTablet ? 50 : 45,
      decoration: BoxDecoration(
        color: _getRankColor(rank, colorScheme),
        borderRadius: BorderRadius.circular(25),
        boxShadow:
            isTopFive
                ? [
                  BoxShadow(
                    color: _getRankColor(rank, colorScheme).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Center(
        child:
            isTopFive
                ? Icon(
                  _getRankIcon(rank),
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                )
                : Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      case 4:
      case 5:
        return colorScheme.primary;
      default:
        return colorScheme.secondary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      default:
        return Icons.person;
    }
  }
}
