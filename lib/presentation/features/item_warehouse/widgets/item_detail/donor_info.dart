import 'package:flutter/material.dart';

class DonorInfo extends StatelessWidget {
  final Map<String, dynamic> donor;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(DateTime) formatJoinDate;
  final VoidCallback onContact;

  const DonorInfo({
    super.key,
    required this.donor,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.formatJoinDate,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Người tặng',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 25,
                backgroundImage: NetworkImage(donor['avatar']),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor['name'],
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: isTablet ? 16 : 14,
                          color: Colors.amber,
                        ),
                        SizedBox(width: isTablet ? 4 : 3),
                        Text(
                          '${donor['rating']}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Text(
                          '${donor['totalDonations']} món đã tặng',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 4 : 3),
                    Text(
                      'Tham gia ${formatJoinDate(donor['joinDate'])}',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              OutlinedButton(
                onPressed: onContact,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                ),
                child: Text(
                  'Liên hệ',
                  style: TextStyle(fontSize: isTablet ? 12 : 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
