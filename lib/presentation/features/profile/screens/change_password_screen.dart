import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordStrong {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumbers &&
        _hasSpecialChar;
  }

  double get _passwordStrengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumbers) score++;
    if (_hasSpecialChar) score++;
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

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate() && _isPasswordStrong) {
      setState(() => _isLoading = true);

      try {
        // Giả lập API call thay đổi mật khẩu
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đổi mật khẩu thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Xóa form sau khi thành công
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          
          // Quay lại màn hình trước đó
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi đổi mật khẩu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // Sử dụng CustomAppBar giống như EditProfileScreen
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        notificationCount: 3, // Có thể truyền số thông báo từ state management
        onNotificationTap: () {
          // Xử lý khi tap vào notification
          context.pushNamed('notifications');
        },
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 40 : 30,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      // Icon bảo mật
                      Container(
                        width: isTablet ? 120 : 100,
                        height: isTablet ? 120 : 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.security_outlined,
                          size: isTablet ? 60 : 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        'Bảo mật tài khoản',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Section
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isTablet ? 32 : 24),

                        // Thông tin bảo mật
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primaryContainer.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: colorScheme.primary,
                                    size: isTablet ? 20 : 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lưu ý bảo mật:',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text(
                                '• Mật khẩu mới phải khác mật khẩu hiện tại\n'
                                '• Không chia sẻ mật khẩu với người khác\n'
                                '• Sử dụng mật khẩu mạnh để bảo vệ tài khoản',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: isTablet ? 14 : 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Mật khẩu hiện tại
                        TextFormField(
                          controller: _currentPasswordController,
                          focusNode: _currentPasswordFocusNode,
                          obscureText: !_isCurrentPasswordVisible,
                          decoration: _inputDecoration(
                            context,
                            label: 'Mật khẩu hiện tại',
                            hint: 'Nhập mật khẩu hiện tại',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _isCurrentPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                              onPressed: () {
                                setState(() =>
                                    _isCurrentPasswordVisible = !_isCurrentPasswordVisible);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) =>
                              _newPasswordFocusNode.requestFocus(),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Mật khẩu mới
                        TextFormField(
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocusNode,
                          obscureText: !_isNewPasswordVisible,
                          decoration: _inputDecoration(
                            context,
                            label: 'Mật khẩu mới',
                            hint: 'Nhập mật khẩu mới',
                            icon: Icons.lock_reset_outlined,
                            suffix: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                              onPressed: () {
                                setState(() =>
                                    _isNewPasswordVisible = !_isNewPasswordVisible);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (value == _currentPasswordController.text) {
                              return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                            }
                            if (!_isPasswordStrong) {
                              return 'Mật khẩu chưa đủ mạnh';
                            }
                            return null;
                          },
                          onChanged: _checkPasswordStrength,
                          onFieldSubmitted: (_) =>
                              _confirmPasswordFocusNode.requestFocus(),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),

                        // Password strength indicator
                        if (_newPasswordController.text.isNotEmpty) ...[
                          Column(
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
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _passwordStrengthScore,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _passwordStrengthColor,
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildPasswordRequirement('Ít nhất 8 ký tự', _hasMinLength),
                                  _buildPasswordRequirement('Chữ hoa', _hasUppercase),
                                  _buildPasswordRequirement('Chữ thường', _hasLowercase),
                                  _buildPasswordRequirement('Số', _hasNumbers),
                                  _buildPasswordRequirement('Ký tự đặc biệt', _hasSpecialChar),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 24 : 20),
                        ],

                        // Xác nhận mật khẩu mới
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: _inputDecoration(
                            context,
                            label: 'Xác nhận mật khẩu mới',
                            hint: 'Nhập lại mật khẩu mới',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                              onPressed: () {
                                setState(() =>
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu mới';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Mật khẩu xác nhận không khớp';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleChangePassword(),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Lời khuyên bảo mật
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    color: colorScheme.primary,
                                    size: isTablet ? 20 : 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mẹo tạo mật khẩu mạnh:',
                                    style: TextStyle(
                                      color: theme.hintColor,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text(
                                '• Kết hợp chữ hoa, chữ thường, số và ký tự đặc biệt\n'
                                '• Sử dụng cụm từ dễ nhớ nhưng khó đoán\n'
                                '• Tránh sử dụng thông tin cá nhân như tên, ngày sinh',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: isTablet ? 14 : 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Nút đổi mật khẩu
                        SizedBox(
                          height: isTablet ? 56 : 50,
                          child: ElevatedButton.icon(
                            onPressed: (_isLoading || !_isPasswordStrong)
                                ? null
                                : _handleChangePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.security),
                            label: Text(
                              _isLoading ? 'Đang cập nhật...' : 'Đổi mật khẩu',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    final theme = Theme.of(context);
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.hintColor.withOpacity(isDisabled ? 0.5 : 0.7),
        fontSize: 16,
      ),
      labelStyle: TextStyle(
        color: isDisabled ? theme.hintColor.withOpacity(0.5) : theme.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: isDisabled
            ? theme.hintColor.withOpacity(0.5)
            : theme.colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          icon,
          color: isDisabled ? theme.hintColor.withOpacity(0.5) : theme.hintColor,
          size: 22,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(left: 12), child: suffix)
          : (isDisabled ? const Icon(Icons.lock_outline, size: 20) : null),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.6),
          width: 1,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
      ),
      errorStyle: TextStyle(
        color: theme.colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}