import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_divider.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_link.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);

    final authState = ref.watch(authProvider);
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, current) {
      // Show error message
      if (current.failure != null &&
          previous?.failure != current.failure &&
          !current.isLoading) {
        context.showErrorSnackBar(current.failure!.message);
        ref.read(authProvider.notifier).clearError();
      }

      // Show success message
      if (current.successMessage != null &&
          previous?.successMessage != current.successMessage) {
        ref.read(authProvider.notifier).clearSuccess();
      }

      // Navigate after login success
      if (current.isLoggedIn &&
          previous?.isLoggedIn != true &&
          current.user != null &&
          !current.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.goNamed('posts');
          }
        });
      }
    });

    // Handle login action
    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Dismiss keyboard
      FocusScope.of(context).unfocus();

      final email = emailController.text.trim();
      final password = passwordController.text;

      await ref
          .read(authProvider.notifier)
          .login(email: email, password: password, device: 'mobile');
    }

    // Handle forgot password
    void handleForgotPassword() {
      context.pushNamed('forgot-password');
    }

    // Handle sign up
    void handleSignUp() {
      context.pushNamed('register');
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: SmartScaffold(
        showBackButton: true,
        appBarType: AppBarType.minimal,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppHeader(
                  title: 'Đăng nhập',
                  subtitle: 'Chào mừng bạn trở lại',
                  icon: Icons.lock_outline,
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isTablet ? 40 : 32),

                          // Email Field
                          TextFormField(
                            controller: emailController,
                            enabled: !authState.isLoading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: CustomInputDecoration.build(
                              context,
                              label: 'Email',
                              hint: 'Nhập email của bạn',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: isTablet ? 24 : 20),

                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            enabled: !authState.isLoading,
                            obscureText: !isPasswordVisible.value,
                            textInputAction: TextInputAction.done,
                            decoration: CustomInputDecoration.build(
                              context,
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu của bạn',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  isPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed:
                                    authState.isLoading
                                        ? null
                                        : () {
                                          isPasswordVisible.value =
                                              !isPasswordVisible.value;
                                        },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu tối thiểu 6 ký tự';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => handleLogin(),
                          ),

                          SizedBox(height: isTablet ? 16 : 12),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  authState.isLoading
                                      ? null
                                      : handleForgotPassword,
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color:
                                      authState.isLoading
                                          ? theme.disabledColor
                                          : theme.colorScheme.primary,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 32 : 24),

                          // Login Button
                          SizedBox(
                            height: isTablet ? 56 : 50,
                            child: ElevatedButton(
                              onPressed:
                                  authState.isLoading ? null : handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor: colorScheme.primary
                                    .withOpacity(0.6),
                                disabledForegroundColor: colorScheme.onPrimary
                                    .withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: authState.isLoading ? 0 : 2,
                              ),
                              child:
                                  authState.isLoading
                                      ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary,
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

                          const AuthDivider(),

                          SizedBox(height: isTablet ? 32 : 24),

                          // Sign Up Link
                          AuthLink(
                            question: 'Bạn chưa có tài khoản? ',
                            linkText: 'Đăng ký',
                            onTap: authState.isLoading ? null : handleSignUp,
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
}
