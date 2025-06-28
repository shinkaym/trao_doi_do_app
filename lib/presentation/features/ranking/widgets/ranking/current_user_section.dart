import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/domain/entities/ranking.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking/user_avatar.dart';

class CurrentUserSection extends StatelessWidget {
  final UserRank yourInfo;
  final int yourRank;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onDetailsPressed;

  const CurrentUserSection({
    super.key,
    required this.yourInfo,
    required this.yourRank,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalGoodDeeds = yourInfo.goodDeeds.fold(
      0,
      (sum, deed) => sum + deed.goodDeedCount,
    );

    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Xếp hạng của bạn',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onDetailsPressed,
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
                label: Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              // Avatar and Rank
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: UserAvatar(
                          avatarBase64: yourInfo.userAvatar,
                          size: isTablet ? 70 : 60,
                          isTablet: isTablet,
                          iconColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$yourRank',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yourInfo.userName,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (yourInfo.major.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        yourInfo.major,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: isTablet ? 8 : 6),
                    Row(
                      children: [
                        StatItem(
                          icon: Icons.star,
                          value: '${yourInfo.goodPoint}',
                          label: 'điểm',
                          isTablet: isTablet,
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        StatItem(
                          icon: Icons.favorite,
                          value: '$totalGoodDeeds',
                          label: 'việc tốt',
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isTablet;

  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: isTablet ? 18 : 16,
        ),
        SizedBox(width: isTablet ? 6 : 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

