import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header_widget.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/auth_divider_widget.dart';
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

    // Handle auth state changes
    void handleAuthStateChange(AuthState? previous, AuthState current) {
      // Clear any previous messages
      if (previous?.failure != null && current.failure == null) {
        ref.read(authProvider.notifier).clearError();
      }
      if (previous?.successMessage != null && current.successMessage == null) {
        ref.read(authProvider.notifier).clearSuccess();
      }

      // Handle success login
      if (current.isLoggedIn && current.user != null && !current.isLoading) {
        if (current.successMessage != null) {
          context.showSuccessSnackBar(current.successMessage!);
          ref.read(authProvider.notifier).clearSuccess();
        }

        // Navigate to main screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.goNamed('posts');
          }
        });
      }

      // Handle login error
      if (current.failure != null && !current.isLoading) {
        context.showErrorSnackBar(getErrorMessage(current.failure!));
        ref.read(authProvider.notifier).clearError();
      }
    }

    // Listen to auth state changes
    ref.listen<AuthState>(
      authProvider,
      (previous, current) => handleAuthStateChange(previous, current),
    );

    // Handle login action
    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) {
        context.showWarningSnackBar("Vui lòng kiểm tra thông tin nhập vào");
        return;
      }

      // Dismiss keyboard
      FocusScope.of(context).unfocus();

      final email = emailController.text.trim();
      final password = passwordController.text;

      try {
        await ref
            .read(authProvider.notifier)
            .login(email: email, password: password, device: 'mobile');
      } catch (e) {
        context.showErrorSnackBar("Đã xảy ra lỗi khi đăng nhập");
      }
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
                AppHeaderWidget(
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

                          const AuthDividerWidget(),

                          SizedBox(height: isTablet ? 32 : 24),

                          // Sign Up Link
                          AuthLinkWidget(
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

// Helper functions
String getErrorMessage(Failure failure) {
  if (failure is ValidationFailure) {
    return failure.message;
  } else if (failure is NetworkFailure) {
    return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
  } else if (failure is ServerFailure) {
    if (failure.statusCode == 401) {
      return 'Email hoặc mật khẩu không chính xác.';
    } else if (failure.statusCode == 429) {
      return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
    }
    return failure.message.isNotEmpty
        ? failure.message
        : 'Đã xảy ra lỗi từ server.';
  }
  return 'Đã xảy ra lỗi không xác định.';
}

// Auth Link Widget
class AuthLinkWidget extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback? onTap;

  const AuthLinkWidget({
    super.key,
    required this.question,
    required this.linkText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: TextStyle(
                color:
                    onTap != null
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
