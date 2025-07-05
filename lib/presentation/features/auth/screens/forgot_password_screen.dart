import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/email_info_card.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/info_card.dart';
import 'package:trao_doi_do_app/presentation/models/password_strength.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_divider.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_link.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// Enum để quản lý các bước reset password
enum ForgotPasswordStep {
  enterEmail, // Bước 1: Nhập email
  verifyOtp, // Bước 2: Xác thực OTP
  enterNewPassword, // Bước 3: Nhập mật khẩu mới
}

// State model cho forgot password
class ForgotPasswordState {
  final ForgotPasswordStep currentStep;
  final bool isLoading;
  final String currentOtp;
  final int remainingTime;
  final bool canResend;
  final String email;

  const ForgotPasswordState({
    this.currentStep = ForgotPasswordStep.enterEmail,
    this.isLoading = false,
    this.currentOtp = '',
    this.remainingTime = 300,
    this.canResend = false,
    this.email = '',
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStep? currentStep,
    bool? isLoading,
    String? currentOtp,
    int? remainingTime,
    bool? canResend,
    String? email,
  }) {
    return ForgotPasswordState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      currentOtp: currentOtp ?? this.currentOtp,
      remainingTime: remainingTime ?? this.remainingTime,
      canResend: canResend ?? this.canResend,
      email: email ?? this.email,
    );
  }
}

// Provider cho forgot password state
final forgotPasswordStateProvider =
    StateNotifierProvider<ForgotPasswordStateNotifier, ForgotPasswordState>((
      ref,
    ) {
      return ForgotPasswordStateNotifier(ref);
    });

class ForgotPasswordStateNotifier extends StateNotifier<ForgotPasswordState> {
  final Ref ref;
  final Debouncer _debouncer = Debouncer();

  ForgotPasswordStateNotifier(this.ref) : super(const ForgotPasswordState());

  // Gửi OTP cho reset password
  Future<void> sendOtp(String email, BuildContext context) async {
    state = state.copyWith(isLoading: true, email: email);

    await ref
        .read(authProvider.notifier)
        .sendOtp(email: email, purpose: 'resetPassword');

    final authState = ref.read(authProvider);

    if (authState.isOtpSent && authState.failure == null) {
      state = state.copyWith(
        isLoading: false,
        currentStep: ForgotPasswordStep.verifyOtp,
        remainingTime: 300, // 5 phút = 300 giây
        canResend: false,
      );
      _startCountdown();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // Xác thực OTP cho reset password
  Future<void> verifyOtp(String otp, BuildContext context) async {
    if (otp.length == 6) {
      state = state.copyWith(isLoading: true);

      await ref
          .read(authProvider.notifier)
          .verifyOtp(email: state.email, otp: otp, purpose: 'resetPassword');

      final authState = ref.read(authProvider);

      if (authState.isOtpVerified && authState.verifyToken != null) {
        state = state.copyWith(
          isLoading: false,
          currentStep: ForgotPasswordStep.enterNewPassword,
        );
      } else {
        state = state.copyWith(isLoading: false);
        updateOtp('');
      }
    }
  }

  // Hoàn tất reset password
  Future<void> completeResetPassword({
    required String password,
    required String rePassword,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true);

    final authState = ref.read(authProvider);
    final verifyToken = authState.verifyToken;

    if (verifyToken == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    await ref
        .read(authProvider.notifier)
        .resetPassword(
          email: state.email,
          password: password,
          rePassword: rePassword,
          verifyToken: verifyToken,
        );

    final newAuthState = ref.read(authProvider);

    state = state.copyWith(isLoading: false);

    if (newAuthState.failure == null) {
      if (context.mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          context.goNamed(RouteNames.login, extra: {'email': state.email});
        }
      }
    }
  }

  void _startCountdown() {
    // Hủy debouncer cũ nếu có
    _debouncer.cancel();

    // Khởi tạo lại state
    state = state.copyWith(remainingTime: 300, canResend: false);

    // Sử dụng debouncer để đếm ngược
    _countdownRecursive();
  }

  void _countdownRecursive() {
    if (state.remainingTime > 0) {
      _debouncer.debounce(
        duration: const Duration(seconds: 1),
        onDebounce: () {
          if (state.remainingTime > 0) {
            state = state.copyWith(remainingTime: state.remainingTime - 1);
            _countdownRecursive(); // Tiếp tục đếm ngược
          } else {
            state = state.copyWith(canResend: true);
          }
        },
      );
    } else {
      state = state.copyWith(canResend: true);
    }
  }

  void updateOtp(String otp) {
    state = state.copyWith(currentOtp: otp);
  }

  void resendOtp(BuildContext context) {
    if (state.canResend) {
      // Reset debouncer khi gửi lại
      _debouncer.cancel();
      sendOtp(state.email, context);
    }
  }

  void goBackToEmail() {
    // Hủy debouncer khi quay lại
    _debouncer.cancel();

    state = state.copyWith(
      currentStep: ForgotPasswordStep.enterEmail,
      currentOtp: '',
      remainingTime: 300,
      canResend: false,
    );

    // Clear auth provider OTP states
    ref.read(authProvider.notifier).resetOtpStates();
  }

  void reset() {
    // Hủy debouncer khi reset
    _debouncer.cancel();

    state = const ForgotPasswordState();
    ref.read(authProvider.notifier).resetOtpStates();
  }

  @override
  void dispose() {
    // Hủy debouncer khi dispose
    _debouncer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Provider for password strength state
final forgotPasswordStrengthProvider =
    StateProvider.autoDispose<PasswordStrength>((ref) {
      return PasswordStrength();
    });

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordStateProvider);
    final forgotPasswordNotifier = ref.read(
      forgotPasswordStateProvider.notifier,
    );
    final authState = ref.watch(authProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Reset state khi dispose
    useEffect(() {
      return () {
        forgotPasswordNotifier.reset();
      };
    }, []);

    // Watch for auth state changes to clear errors
    useEffect(() {
      if (authState.failure != null) {
        Future.microtask(() {
          context.showErrorSnackBar(authState.failure!.message);
          ref.read(authProvider.notifier).clearError();
        });
      }

      if (authState.successMessage != null) {
        Future.microtask(() {
          context.showSuccessSnackBar(authState.successMessage!);
          ref.read(authProvider.notifier).clearSuccess();
        });
      }
      return null;
    }, [authState.failure, authState.successMessage]);

    String getTitle() {
      switch (forgotPasswordState.currentStep) {
        case ForgotPasswordStep.enterEmail:
          return 'Quên mật khẩu';
        case ForgotPasswordStep.verifyOtp:
          return 'Nhập mã OTP';
        case ForgotPasswordStep.enterNewPassword:
          return 'Đặt mật khẩu mới';
      }
    }

    String getSubtitle() {
      switch (forgotPasswordState.currentStep) {
        case ForgotPasswordStep.enterEmail:
          return 'Nhập email để lấy lại mật khẩu';
        case ForgotPasswordStep.verifyOtp:
          return 'Nhập mã OTP được gửi đến email của bạn';
        case ForgotPasswordStep.enterNewPassword:
          return 'Nhập mật khẩu mới cho tài khoản của bạn';
      }
    }

    IconData getIcon() {
      switch (forgotPasswordState.currentStep) {
        case ForgotPasswordStep.enterEmail:
          return Icons.lock_reset_outlined;
        case ForgotPasswordStep.verifyOtp:
          return Icons.security_outlined;
        case ForgotPasswordStep.enterNewPassword:
          return Icons.vpn_key_outlined;
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: SmartScaffold(
        title: getTitle(),
        appBarType: AppBarType.minimal,
        showBackButton: true,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppHeader(
                  title: getTitle(),
                  subtitle: getSubtitle(),
                  icon: getIcon(),
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: _buildStepContent(
                      context,
                      ref,
                      forgotPasswordState,
                      forgotPasswordNotifier,
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

  Widget _buildStepContent(
    BuildContext context,
    WidgetRef ref,
    ForgotPasswordState forgotPasswordState,
    ForgotPasswordStateNotifier forgotPasswordNotifier,
  ) {
    switch (forgotPasswordState.currentStep) {
      case ForgotPasswordStep.enterEmail:
        return _EmailStepContent(
          forgotPasswordState: forgotPasswordState,
          forgotPasswordNotifier: forgotPasswordNotifier,
        );
      case ForgotPasswordStep.verifyOtp:
        return _OtpStepContent(
          forgotPasswordState: forgotPasswordState,
          forgotPasswordNotifier: forgotPasswordNotifier,
        );
      case ForgotPasswordStep.enterNewPassword:
        return _NewPasswordStepContent(
          forgotPasswordState: forgotPasswordState,
          forgotPasswordNotifier: forgotPasswordNotifier,
        );
    }
  }
}

// Widget cho bước nhập email
class _EmailStepContent extends HookConsumerWidget {
  final ForgotPasswordState forgotPasswordState;
  final ForgotPasswordStateNotifier forgotPasswordNotifier;

  const _EmailStepContent({
    required this.forgotPasswordState,
    required this.forgotPasswordNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    void handleSendOtp() async {
      if (formKey.currentState!.validate()) {
        await forgotPasswordNotifier.sendOtp(emailController.text, context);
      }
    }

    void handleBackToLogin() {
      context.goNamed('login');
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Mô tả
          InfoCard(
            icon: Icons.info_outline,
            title: 'Hướng dẫn lấy lại mật khẩu',
            content:
                'Nhập địa chỉ email tài khoản của bạn. Chúng tôi sẽ gửi mã OTP để xác thực và cho phép bạn đặt lại mật khẩu mới.',
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Email input
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Email',
              hint: 'Nhập email tài khoản của bạn',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onFieldSubmitted: (_) => handleSendOtp(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Nút gửi OTP
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed: forgotPasswordState.isLoading ? null : handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  forgotPasswordState.isLoading
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
                        'Gửi mã OTP',
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

          // Link quay lại đăng nhập
          AuthLink(
            question: 'Nhớ lại mật khẩu? ',
            linkText: 'Đăng nhập',
            onTap: handleBackToLogin,
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }
}

// Widget cho bước xác thực OTP
class _OtpStepContent extends HookConsumerWidget {
  final ForgotPasswordState forgotPasswordState;
  final ForgotPasswordStateNotifier forgotPasswordNotifier;

  const _OtpStepContent({
    required this.forgotPasswordState,
    required this.forgotPasswordNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Clear OTP controller khi OTP được reset
    useEffect(() {
      if (forgotPasswordState.currentOtp.isEmpty) {
        otpController.clear();
      }
      return null;
    }, [forgotPasswordState.currentOtp]);

    void handleVerifyOtp() async {
      await forgotPasswordNotifier.verifyOtp(
        forgotPasswordState.currentOtp,
        context,
      );
    }

    void handleResendOtp() {
      forgotPasswordNotifier.resendOtp(context);
    }

    void handleBackToLogin() {
      context.goNamed('login');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Email info
        EmailInfoCard(email: forgotPasswordState.email),

        SizedBox(height: isTablet ? 32 : 24),

        // OTP Input
        Text(
          'Nhập mã OTP (6 ký tự)',
          style: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: otpController,
          keyboardType: TextInputType.text,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: isTablet ? 60 : 50,
            fieldWidth: isTablet ? 50 : 40,
            activeFillColor: Colors.transparent,
            selectedFillColor: Colors.transparent,
            inactiveFillColor: Colors.transparent,
            activeColor: colorScheme.primary,
            selectedColor: colorScheme.primary,
            inactiveColor: theme.dividerColor,
            borderWidth: 2,
          ),
          enableActiveFill: true,
          cursorColor: colorScheme.primary,
          textStyle: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          onChanged: (value) {
            forgotPasswordNotifier.updateOtp(value);
          },
          onCompleted: (value) {
            handleVerifyOtp();
          },
        ),
        SizedBox(height: isTablet ? 24 : 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              forgotPasswordState.canResend
                  ? 'Có thể gửi lại mã'
                  : 'Gửi lại sau: ${forgotPasswordNotifier.formatTime(forgotPasswordState.remainingTime)}',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            GestureDetector(
              onTap: forgotPasswordState.canResend ? handleResendOtp : null,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  color:
                      forgotPasswordState.canResend
                          ? colorScheme.primary
                          : theme.disabledColor,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  decoration:
                      forgotPasswordState.canResend
                          ? TextDecoration.underline
                          : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Verify button
        SizedBox(
          height: isTablet ? 56 : 50,
          child: ElevatedButton(
            onPressed:
                (forgotPasswordState.isLoading ||
                        forgotPasswordState.currentOtp.length != 6)
                    ? null
                    : handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                forgotPasswordState.isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      'Xác thực OTP',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Divider
        const AuthDivider(),
        SizedBox(height: isTablet ? 32 : 24),

        // Back to login
        AuthLink(
          question: 'Nhớ lại mật khẩu? ',
          linkText: 'Đăng nhập',
          onTap: handleBackToLogin,
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}

// Widget cho bước nhập mật khẩu mới
class _NewPasswordStepContent extends HookConsumerWidget {
  final ForgotPasswordState forgotPasswordState;
  final ForgotPasswordStateNotifier forgotPasswordNotifier;

  const _NewPasswordStepContent({
    required this.forgotPasswordState,
    required this.forgotPasswordNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Text controllers
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Visibility states
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Watch password strength
    final passwordStrength = ref.watch(forgotPasswordStrengthProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    // Password strength check function
    void checkPasswordStrength(String password) {
      final newStrength = PasswordStrength(
        hasMinLength: password.length >= 8,
        hasUppercase: password.contains(RegExp(r'[A-Z]')),
        hasLowercase: password.contains(RegExp(r'[a-z]')),
        hasNumbers: password.contains(RegExp(r'[0-9]')),
        hasSpecialChar: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      );
      ref.read(forgotPasswordStrengthProvider.notifier).state = newStrength;
    }

    // Complete reset password handler
    Future<void> handleCompleteResetPassword() async {
      if (formKey.currentState!.validate() && passwordStrength.isStrong) {
        await forgotPasswordNotifier.completeResetPassword(
          password: passwordController.text,
          rePassword: confirmPasswordController.text,
          context: context,
        );
      }
    }

    // Listen to password changes
    useEffect(() {
      void listener() {
        checkPasswordStrength(passwordController.text);
      }

      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, [passwordController]);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Email info (read-only)
          InfoCard(
            icon: Icons.email_outlined,
            title: 'Email đã xác thực:',
            content: forgotPasswordState.email,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Mật khẩu mới
          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible.value,
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới của bạn',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
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

          // Xác nhận mật khẩu mới
          TextFormField(
            controller: confirmPasswordController,
            obscureText: !isConfirmPasswordVisible.value,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Xác nhận mật khẩu mới',
              hint: 'Nhập lại mật khẩu mới của bạn',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  isConfirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  isConfirmPasswordVisible.value =
                      !isConfirmPasswordVisible.value;
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu mới';
              }
              if (value != passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => handleCompleteResetPassword(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Security tips
          InfoCard(
            icon: Icons.security_outlined,
            title: 'Bảo mật mật khẩu:',
            content:
                'Mật khẩu mạnh bao gồm ít nhất 8 ký tự, có chữ hoa, chữ thường, số và ký tự đặc biệt. Không sử dụng lại mật khẩu cũ.',
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Complete reset password button
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed:
                  (forgotPasswordState.isLoading || !passwordStrength.isStrong)
                      ? null
                      : handleCompleteResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  forgotPasswordState.isLoading
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

          // Divider
          const AuthDivider(),
          SizedBox(height: isTablet ? 32 : 24),

          // Back to login
          AuthLink(
            question: 'Hoàn tất đặt lại mật khẩu? ',
            linkText: 'Đăng nhập ngay',
            onTap: () => context.goNamed('login'),
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }
}
