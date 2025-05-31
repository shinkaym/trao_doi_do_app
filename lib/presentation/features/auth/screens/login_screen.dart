import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      context.goNamed('posts');
    }
  }

  void _handleForgotPassword() {
    context.pushNamed('forgot-password');
  }

  void _handleSignUp() {
    context.pushNamed('register');
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
                // Fallback nếu không thể pop, có thể điều hướng đến màn hình mặc định
                context.goNamed('posts');
              }
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
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
                            Icons.lock_outline,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          'Đăng nhập',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'Chào mừng bạn trở lại',
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
                          TextFormField(
                            controller: _emailController,
                            // keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              context,
                              label: 'Email',
                              hint: 'Nhập email của bạn',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Vui lòng nhập email';
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 20),
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
                              if (value == null || value.isEmpty)
                                return 'Vui lòng nhập mật khẩu';
                              if (value.length < 6)
                                return 'Mật khẩu tối thiểu 6 ký tự';
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),
                          SizedBox(
                            height: isTablet ? 56 : 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
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
                                        'Đăng nhập',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bạn chưa có tài khoản? ',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleSignUp,
                                child: Text(
                                  'Đăng ký',
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
