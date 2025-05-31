import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
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
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _isPasswordStrong) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Chờ 1 giây sau khi hiển thị snackbar rồi mới chuyển trang
        await Future.delayed(const Duration(seconds: 1));
        
        // Điều hướng về màn hình đăng nhập
        if (mounted) {
          context.goNamed('login');
        }
      }
    }
  }

  void _handleLogin() {
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
                context.goNamed('posts');
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
                            Icons.person_add_outlined,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          'Đăng ký',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'Tạo tài khoản mới',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18 : 16,
                          ),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isTablet ? 40 : 32),

                          // Họ và tên
                          TextFormField(
                            controller: _fullNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              context,
                              label: 'Họ và tên',
                              hint: 'Nhập họ và tên của bạn',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              if (value.trim().length < 2) {
                                return 'Họ và tên phải có ít nhất 2 ký tự';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              context,
                              label: 'Email',
                              hint: 'Nhập email của bạn',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 20),

                          // Số điện thoại
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              context,
                              label: 'Số điện thoại',
                              hint: 'Nhập số điện thoại của bạn',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              // Kiểm tra số điện thoại Việt Nam (10-11 số, bắt đầu bằng 0)
                              if (!RegExp(r'^0[0-9]{9,10}$').hasMatch(value)) {
                                return 'Số điện thoại không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 20),

                          // Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: _inputDecoration(
                              context,
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu của bạn',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (!_isPasswordStrong) {
                                return 'Mật khẩu chưa đủ mạnh';
                              }
                              return null;
                            },
                            onChanged: _checkPasswordStrength,
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

                          // Xác nhận mật khẩu
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: _inputDecoration(
                              context,
                              label: 'Xác nhận mật khẩu',
                              hint: 'Nhập lại mật khẩu của bạn',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
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
                            onFieldSubmitted: (_) => _handleRegister(),
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
                                  '• Không chia sẻ mật khẩu với người khác\n'
                                  '• Thay đổi mật khẩu định kỳ để đảm bảo bảo mật\n',
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

                          // Nút đăng ký
                          SizedBox(
                            height: isTablet ? 56 : 50,
                            child: ElevatedButton(
                              onPressed: (_isLoading || !_isPasswordStrong) 
                                  ? null 
                                  : _handleRegister,
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Đăng ký',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: theme.dividerColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'hoặc',
                                  style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: theme.dividerColor),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Link đăng nhập
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleLogin,
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
                    ),
                  ),
                ),
              ],
            ),
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