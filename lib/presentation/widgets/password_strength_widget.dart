import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSpecialChar;

  const PasswordStrengthWidget({
    super.key,
    required this.password,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumbers,
    required this.hasSpecialChar,
  });

  double get _passwordStrengthScore {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumbers) score++;
    if (hasSpecialChar) score++;
    return score / 5.0;
  }

  Color get _passwordStrengthColor {
    if (_passwordStrengthScore < 0.3) return Colors.red;
    if (_passwordStrengthScore < 0.6) return Colors.orange;
    if (_passwordStrengthScore < 0.8) return Colors.yellow[700]!;
    return Colors.green;
  }

  String get _passwordStrengthText {
    if (_passwordStrengthScore < 0.3) return 'Yếu';
    if (_passwordStrengthScore < 0.6) return 'Trung bình';
    if (_passwordStrengthScore < 0.8) return 'Mạnh';
    return 'Rất mạnh';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Độ mạnh mật khẩu: ',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _passwordStrengthScore,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _PasswordRequirement(text: 'Ít nhất 8 ký tự', isMet: hasMinLength),
            _PasswordRequirement(text: 'Chữ hoa', isMet: hasUppercase),
            _PasswordRequirement(text: 'Chữ thường', isMet: hasLowercase),
            _PasswordRequirement(text: 'Số', isMet: hasNumbers),
            _PasswordRequirement(text: 'Ký tự đặc biệt', isMet: hasSpecialChar),
          ],
        ),
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMet
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            size: 12,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green : theme.hintColor,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}