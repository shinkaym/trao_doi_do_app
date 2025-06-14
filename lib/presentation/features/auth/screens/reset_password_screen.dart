import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/models/password_strength.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_divider.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_link.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class ResetPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const ResetPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

// Providers
final passwordStrengthProvider =
    StateNotifierProvider<PasswordStrengthNotifier, PasswordStrength>((ref) {
      return PasswordStrengthNotifier();
    });

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>((ref) {
      return ResetPasswordNotifier();
    });

// Notifiers
class PasswordStrengthNotifier extends StateNotifier<PasswordStrength> {
  PasswordStrengthNotifier() : super(const PasswordStrength());

  void checkPasswordStrength(String password) {
    state = PasswordStrength(
      hasMinLength: password.length >= 8,
      hasUppercase: password.contains(RegExp(r'[A-Z]')),
      hasLowercase: password.contains(RegExp(r'[a-z]')),
      hasNumbers: password.contains(RegExp(r'[0-9]')),
      hasSpecialChar: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    );
  }

  void reset() {
    state = const PasswordStrength();
  }
}

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  ResetPasswordNotifier() : super(const ResetPasswordState());

  Future<void> resetPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Giả lập API call reset password
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Có lỗi xảy ra khi đặt lại mật khẩu',
      );
    }
  }

  void reset() {
    state = const ResetPasswordState();
  }
}

class ResetPasswordScreen extends HookConsumerWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();

    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Providers
    final passwordStrength = ref.watch(passwordStrengthProvider);
    final resetPasswordState = ref.watch(resetPasswordProvider);

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Effects
    useEffect(() {
      void onPasswordChanged() {
        ref
            .read(passwordStrengthProvider.notifier)
            .checkPasswordStrength(passwordController.text);
      }

      passwordController.addListener(onPasswordChanged);
      return () => passwordController.removeListener(onPasswordChanged);
    }, [passwordController]);

    useEffect(() {
      if (resetPasswordState.isSuccess) {
        context.showSuccessSnackBar('Đặt lại mật khẩu thành công!');

        // Tự động chuyển về màn hình đăng nhập sau 3 giây
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            context.goNamed('login');
          }
        });
      }
      return null;
    }, [resetPasswordState.isSuccess]);

    useEffect(() {
      if (resetPasswordState.error != null) {
        context.showErrorSnackBar(resetPasswordState.error!);
      }
      return null;
    }, [resetPasswordState.error]);

    // Methods
    void handleResetPassword() async {
      if (formKey.currentState!.validate() && passwordStrength.isStrong) {
        await ref
            .read(resetPasswordProvider.notifier)
            .resetPassword(email, passwordController.text);
      }
    }

    void handleBackToLogin() {
      context.goNamed('login');
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
                            resetPasswordState.isSuccess
                                ? Icons.check_circle_outline
                                : Icons.lock_open_outlined,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          resetPasswordState.isSuccess
                              ? 'Thành công!'
                              : 'Đặt lại mật khẩu',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          resetPasswordState.isSuccess
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
                        resetPasswordState.isSuccess
                            ? _buildSuccessContent(context, handleBackToLogin)
                            : _buildFormContent(
                              context,
                              formKey,
                              passwordController,
                              confirmPasswordController,
                              passwordFocusNode,
                              confirmPasswordFocusNode,
                              isPasswordVisible,
                              isConfirmPasswordVisible,
                              passwordStrength,
                              resetPasswordState,
                              handleResetPassword,
                              handleBackToLogin,
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

  Widget _buildFormContent(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
    FocusNode passwordFocusNode,
    FocusNode confirmPasswordFocusNode,
    ValueNotifier<bool> isPasswordVisible,
    ValueNotifier<bool> isConfirmPasswordVisible,
    PasswordStrength passwordStrength,
    ResetPasswordState resetPasswordState,
    VoidCallback handleResetPassword,
    VoidCallback handleBackToLogin,
  ) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Form(
      key: formKey,
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
                        email,
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
          ValueListenableBuilder<bool>(
            valueListenable: isPasswordVisible,
            builder: (context, visible, _) {
              return TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: !visible,
                decoration: CustomInputDecoration.build(
                  context,
                  label: 'Mật khẩu mới',
                  hint: 'Nhập mật khẩu mới',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      visible ? Icons.visibility_off : Icons.visibility,
                      color: theme.hintColor,
                    ),
                    onPressed: () {
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (!passwordStrength.isStrong) {
                    return 'Mật khẩu chưa đủ mạnh';
                  }
                  return null;
                },
                onFieldSubmitted:
                    (_) => confirmPasswordFocusNode.requestFocus(),
              );
            },
          ),
          SizedBox(height: isTablet ? 16 : 12),

          if (passwordController.text.isNotEmpty) ...[
            // Password strength indicator
            PasswordStrengthWidget(
              password: passwordController.text,
              hasMinLength: passwordStrength.hasMinLength,
              hasUppercase: passwordStrength.hasUppercase,
              hasLowercase: passwordStrength.hasLowercase,
              hasNumbers: passwordStrength.hasNumbers,
              hasSpecialChar: passwordStrength.hasSpecialChar,
            ),
            SizedBox(height: isTablet ? 16 : 12),
          ],

          // Confirm Password input
          ValueListenableBuilder<bool>(
            valueListenable: isConfirmPasswordVisible,
            builder: (context, visible, _) {
              return TextFormField(
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocusNode,
                obscureText: !visible,
                decoration: CustomInputDecoration.build(
                  context,
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu mới',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      visible ? Icons.visibility_off : Icons.visibility,
                      color: theme.hintColor,
                    ),
                    onPressed: () {
                      isConfirmPasswordVisible.value =
                          !isConfirmPasswordVisible.value;
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => handleResetPassword(),
              );
            },
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

          // Reset Password button
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed:
                  (resetPasswordState.isLoading || !passwordStrength.isStrong)
                      ? null
                      : handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  resetPasswordState.isLoading
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
          const AuthDivider(),
          SizedBox(height: isTablet ? 32 : 24),

          // Back to login
          AuthLink(
            question: 'Nhớ mật khẩu cũ? ',
            linkText: 'Đăng nhập',
            onTap: handleBackToLogin,
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    VoidCallback handleBackToLogin,
  ) {
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
            onPressed: handleBackToLogin,
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
