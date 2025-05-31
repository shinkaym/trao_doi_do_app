import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
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

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate() && _isPasswordStrong) {
      setState(() => _isLoading = true);

      // Giả lập API call reset password
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Tự động chuyển về màn hình đăng nhập sau 3 giây
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.goNamed('login');
        }
      });
    }
  }

  void _handleBackToLogin() {
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('login');
              }
            },
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
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
                      vertical: isTablet ? 60 : 40,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _isSuccess
                                ? Icons.check_circle_outline
                                : Icons.lock_open_outlined,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          _isSuccess ? 'Thành công!' : 'Đặt lại mật khẩu',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          _isSuccess
                              ? 'Mật khẩu đã được cập nhật thành công'
                              : 'Tạo mật khẩu mới cho tài khoản của bạn',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child:
                        _isSuccess
                            ? _buildSuccessContent()
                            : _buildFormContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Email info
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
            child: Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: colorScheme.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đặt lại mật khẩu cho tài khoản:',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // New Password input
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            decoration: _inputDecoration(
              context,
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: theme.hintColor,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }
              if (!_isPasswordStrong) {
                return 'Mật khẩu chưa đủ mạnh';
              }
              return null;
            },
            onChanged: _checkPasswordStrength,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Password strength indicator
          if (_passwordController.text.isNotEmpty) ...[
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
                    _buildPasswordRequirement(
                      'Ký tự đặc biệt',
                      _hasSpecialChar,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 20),
          ],

          // Confirm Password input
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: !_isConfirmPasswordVisible,
            decoration: _inputDecoration(
              context,
              label: 'Xác nhận mật khẩu',
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
                  setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != _passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleResetPassword(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Security tips
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
                      Icons.security_outlined,
                      color: colorScheme.primary,
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Lời khuyên bảo mật:',
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
                  // '• Sử dụng mật khẩu duy nhất cho mỗi tài khoản\n'
                  '• Không chia sẻ mật khẩu với người khác\n'
                  '• Thay đổi mật khẩu định kỳ để đảm bảo bảo mật\n',
                  // '• Sử dụng trình quản lý mật khẩu'
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

          // Reset Password button
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed:
                  (_isLoading || !_isPasswordStrong)
                      ? null
                      : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Đặt lại mật khẩu',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nhớ mật khẩu cũ? ',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              GestureDetector(
                onTap: _handleBackToLogin,
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Success message
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: isTablet ? 64 : 48,
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                'Đặt lại mật khẩu thành công!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Mật khẩu của bạn đã được cập nhật.\nBây giờ bạn có thể đăng nhập với mật khẩu mới.',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Auto redirect info
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
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  'Bạn sẽ được chuyển về trang đăng nhập sau 3 giây...',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: isTablet ? 16 : 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Login now button
        SizedBox(
          height: isTablet ? 56 : 50,
          child: ElevatedButton(
            onPressed: _handleBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Đăng nhập ngay',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isMet
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isMet
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
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.hintColor.withOpacity(0.7),
        fontSize: 16,
      ),
      labelStyle: TextStyle(
        color: theme.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(icon, color: theme.hintColor, size: 22),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      suffixIcon:
          suffix != null
              ? Padding(padding: const EdgeInsets.only(left: 12), child: suffix)
              : null,
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
