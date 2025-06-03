import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/auth_divider_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';

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
      context.showSuccessSnackBar('Đặt lại mật khẩu thành công!');

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
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

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
              if (context.canPop) {
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
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

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
            decoration: CustomInputDecoration.build(
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

          if (_passwordController.text.isNotEmpty) ...[
            // Password strength indicator
            PasswordStrengthWidget(
              password: _passwordController.text,
              hasMinLength: _hasMinLength,
              hasUppercase: _hasUppercase,
              hasLowercase: _hasLowercase,
              hasNumbers: _hasNumbers,
              hasSpecialChar: _hasSpecialChar,
            ),
          ],
          // Confirm Password input
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: !_isConfirmPasswordVisible,
            decoration: CustomInputDecoration.build(
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
          SizedBox(height: isTablet ? 32 : 24),

          // Divider
          const AuthDividerWidget(),
          SizedBox(height: isTablet ? 32 : 24),

          // Back to login
          AuthLinkWidget(
            question: 'Nhớ mật khẩu cũ? ',
            linkText: 'Đăng nhập',
            onTap: _handleBackToLogin,
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

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
}
