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
      return Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
        child: Center(child: CircularProgressIndicator()),
      );
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