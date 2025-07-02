import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trao_doi_do_app/domain/entities/setting.dart';

class ContactInfoSection extends HookConsumerWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const ContactInfoSection({
    super.key,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    useEffect(() {
      // Chỉ load nếu chưa có dữ liệu và không đang loading
      if (settingsState.settings.isEmpty && !settingsState.isLoading) {
        Future.microtask(() {
          ref.read(settingsProvider.notifier).loadSettings();
        });
      }
      return null;
    }, []); // Empty dependency array = chỉ chạy 1 lần

    if (settingsState.isLoading) {
      return ContactInfoSkeleton(isTablet: isTablet, colorScheme: colorScheme);
    }

    if (settingsState.settings.isEmpty) {
      return const SizedBox.shrink();
    }

    final contactInfo = _getContactInfo(settingsState.settings);

    // Nếu không có thông tin nào thì không hiển thị
    if (contactInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactHeader(isTablet: isTablet, colorScheme: colorScheme),

          SizedBox(height: isTablet ? 16 : 12),

          _ContactInfoCard(
            contactInfo: contactInfo,
            isTablet: isTablet,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Map<String, String> _getContactInfo(List<Setting> settings) {
    final Map<String, String> info = {};

    for (final setting in settings) {
      switch (setting.key) {
        case 'phoneNumber':
        case 'location':
        case 'description':
        case 'startMorningTime':
        case 'endMorningTime':
        case 'startAfternoonTime':
        case 'endAfternoonTime':
        case 'workDay':
        case 'email':
          if (setting.value.isNotEmpty) {
            info[setting.key] = setting.value;
          }
          break;
      }
    }

    return info;
  }
}

class _ContactHeader extends StatelessWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const _ContactHeader({required this.isTablet, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.contact_support,
            color: Colors.white,
            size: isTablet ? 20 : 18,
          ),
        ),

        SizedBox(width: isTablet ? 16 : 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Hỗ trợ và giải đáp thắc mắc',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final Map<String, String> contactInfo;
  final bool isTablet;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ContactInfoCard({
    required this.contactInfo,
    required this.isTablet,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (contactInfo['description'] != null) ...[
            _buildDescriptionSection(),
            SizedBox(height: isTablet ? 20 : 16),
          ],

          // Contact Methods - Simplified
          if (_hasContactMethods()) ...[
            _buildSimpleContactSection(),
            SizedBox(height: isTablet ? 20 : 16),
          ],

          // Working Hours
          if (_hasWorkingHours()) ...[_buildWorkingHoursSection()],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: isTablet ? 18 : 16,
              color: Colors.blue.shade600,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Về chúng tôi',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 12 : 10),

        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: Text(
            contactInfo['description']!,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.black, // Đổi thành màu đen cố định
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Simplified contact section
  Widget _buildSimpleContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liên hệ',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        SizedBox(height: isTablet ? 12 : 10),

        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              if (contactInfo['phoneNumber'] != null)
                _SimpleContactItem(
                  icon: Icons.phone,
                  label: 'Điện thoại',
                  value: contactInfo['phoneNumber']!,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  onTap: () => _launchPhone(contactInfo['phoneNumber']!),
                ),

              if (contactInfo['email'] != null)
                _SimpleContactItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: contactInfo['email']!,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  onTap: () => _launchEmail(contactInfo['email']!),
                ),

              if (contactInfo['location'] != null)
                _SimpleContactItem(
                  icon: Icons.location_on,
                  label: 'Địa chỉ',
                  value: contactInfo['location']!,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: isTablet ? 18 : 16,
              color: Colors.orange.shade600,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Giờ làm việc',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 12 : 10),

        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100, width: 1),
          ),
          child: Column(
            children: [
              if (contactInfo['workDay'] != null)
                _WorkingTimeItem(
                  icon: Icons.calendar_today,
                  label: 'Ngày làm việc',
                  value: contactInfo['workDay']!,
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                ),

              if (_hasMorningTime())
                _WorkingTimeItem(
                  icon: Icons.wb_sunny,
                  label: 'Buổi sáng',
                  value:
                      '${contactInfo['startMorningTime']} - ${contactInfo['endMorningTime']}',
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                ),

              if (_hasAfternoonTime())
                _WorkingTimeItem(
                  icon: Icons.wb_twilight,
                  label: 'Buổi chiều',
                  value:
                      '${contactInfo['startAfternoonTime']} - ${contactInfo['endAfternoonTime']}',
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasContactMethods() {
    return contactInfo['phoneNumber'] != null ||
        contactInfo['email'] != null ||
        contactInfo['location'] != null;
  }

  bool _hasWorkingHours() {
    return contactInfo['workDay'] != null ||
        _hasMorningTime() ||
        _hasAfternoonTime();
  }

  bool _hasMorningTime() {
    return contactInfo['startMorningTime'] != null &&
        contactInfo['endMorningTime'] != null;
  }

  bool _hasAfternoonTime() {
    return contactInfo['startAfternoonTime'] != null &&
        contactInfo['endAfternoonTime'] != null;
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// Simplified contact item widget
class _SimpleContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isTablet;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _SimpleContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isTablet,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 8 : 6,
          horizontal: isTablet ? 4 : 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: isTablet ? 16 : 14, color: colorScheme.primary),
            SizedBox(width: isTablet ? 12 : 10),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: isTablet ? 12 : 10,
                color: colorScheme.primary.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkingTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isTablet;
  final ColorScheme colorScheme;

  const _WorkingTimeItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        children: [
          Icon(icon, size: isTablet ? 16 : 14, color: Colors.orange.shade600),

          SizedBox(width: isTablet ? 12 : 10),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: Colors.black, // Đổi thành màu đen cố định
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: Colors.black, // Đổi thành màu đen cố định
                    fontWeight: FontWeight.w600,
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

// Thêm class ContactInfoSkeleton vào cuối file ContactInfoSection

class ContactInfoSkeleton extends StatefulWidget {
  final bool isTablet;
  final ColorScheme colorScheme;

  const ContactInfoSkeleton({
    super.key,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  State<ContactInfoSkeleton> createState() => _ContactInfoSkeletonState();
}

class _ContactInfoSkeletonState extends State<ContactInfoSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBaseColor() {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  Color _getHighlightColor() {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [_getBaseColor(), _getHighlightColor(), _getBaseColor()],
              stops: [0.0, _animation.value, 1.0],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              _buildShimmerContainer(
                width: widget.isTablet ? 44 : 38,
                height: widget.isTablet ? 44 : 38,
                borderRadius: BorderRadius.circular(12),
              ),
              SizedBox(width: widget.isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(
                      width: widget.isTablet ? 160 : 140,
                      height: widget.isTablet ? 20 : 18,
                    ),
                    SizedBox(height: 4),
                    _buildShimmerContainer(
                      width: widget.isTablet ? 180 : 160,
                      height: widget.isTablet ? 12 : 11,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: widget.isTablet ? 16 : 12),

          // Card skeleton
          Container(
            padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: widget.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description section skeleton
                Row(
                  children: [
                    _buildShimmerContainer(
                      width: widget.isTablet ? 18 : 16,
                      height: widget.isTablet ? 18 : 16,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    SizedBox(width: widget.isTablet ? 8 : 6),
                    _buildShimmerContainer(
                      width: widget.isTablet ? 100 : 90,
                      height: widget.isTablet ? 16 : 14,
                    ),
                  ],
                ),
                SizedBox(height: widget.isTablet ? 12 : 10),
                Container(
                  padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildShimmerContainer(
                        width: double.infinity,
                        height: widget.isTablet ? 14 : 13,
                      ),
                      SizedBox(height: 8),
                      _buildShimmerContainer(
                        width: double.infinity,
                        height: widget.isTablet ? 14 : 13,
                      ),
                      SizedBox(height: 8),
                      _buildShimmerContainer(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: widget.isTablet ? 14 : 13,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: widget.isTablet ? 20 : 16),

                // Contact section skeleton
                _buildShimmerContainer(
                  width: widget.isTablet ? 80 : 70,
                  height: widget.isTablet ? 16 : 14,
                ),
                SizedBox(height: widget.isTablet ? 12 : 10),
                Container(
                  padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Phone skeleton
                      _buildContactItemSkeleton(),
                      SizedBox(height: widget.isTablet ? 8 : 6),
                      // Email skeleton
                      _buildContactItemSkeleton(),
                      SizedBox(height: widget.isTablet ? 8 : 6),
                      // Location skeleton
                      _buildContactItemSkeleton(),
                    ],
                  ),
                ),

                SizedBox(height: widget.isTablet ? 20 : 16),

                // Working hours section skeleton
                Row(
                  children: [
                    _buildShimmerContainer(
                      width: widget.isTablet ? 18 : 16,
                      height: widget.isTablet ? 18 : 16,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    SizedBox(width: widget.isTablet ? 8 : 6),
                    _buildShimmerContainer(
                      width: widget.isTablet ? 100 : 90,
                      height: widget.isTablet ? 16 : 14,
                    ),
                  ],
                ),
                SizedBox(height: widget.isTablet ? 12 : 10),
                Container(
                  padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Work day skeleton
                      _buildWorkingTimeSkeleton(),
                      SizedBox(height: widget.isTablet ? 8 : 6),
                      // Morning time skeleton
                      _buildWorkingTimeSkeleton(),
                      SizedBox(height: widget.isTablet ? 8 : 6),
                      // Afternoon time skeleton
                      _buildWorkingTimeSkeleton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItemSkeleton() {
    return Row(
      children: [
        _buildShimmerContainer(
          width: widget.isTablet ? 16 : 14,
          height: widget.isTablet ? 16 : 14,
          borderRadius: BorderRadius.circular(2),
        ),
        SizedBox(width: widget.isTablet ? 12 : 10),
        _buildShimmerContainer(
          width: widget.isTablet ? 80 : 70,
          height: widget.isTablet ? 13 : 12,
        ),
        SizedBox(width: widget.isTablet ? 8 : 6),
        Expanded(
          child: _buildShimmerContainer(
            width: double.infinity,
            height: widget.isTablet ? 13 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingTimeSkeleton() {
    return Row(
      children: [
        _buildShimmerContainer(
          width: widget.isTablet ? 16 : 14,
          height: widget.isTablet ? 16 : 14,
          borderRadius: BorderRadius.circular(2),
        ),
        SizedBox(width: widget.isTablet ? 12 : 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerContainer(
                width: widget.isTablet ? 90 : 80,
                height: widget.isTablet ? 13 : 12,
              ),
              _buildShimmerContainer(
                width: widget.isTablet ? 100 : 90,
                height: widget.isTablet ? 13 : 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
