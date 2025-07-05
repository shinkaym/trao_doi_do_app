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

// Enum để quản lý các bước đăng ký
enum RegisterStep {
  enterEmail, // Bước 1: Nhập email
  verifyOtp, // Bước 2: Xác thực OTP
  enterDetails, // Bước 3: Nhập thông tin chi tiết
}

// State model cho register
class RegisterState {
  final RegisterStep currentStep;
  final bool isLoading;
  final String currentOtp;
  final int remainingTime;
  final bool canResend;
  final String email;

  const RegisterState({
    this.currentStep = RegisterStep.enterEmail,
    this.isLoading = false,
    this.currentOtp = '',
    this.remainingTime = 300,
    this.canResend = false,
    this.email = '',
  });

  RegisterState copyWith({
    RegisterStep? currentStep,
    bool? isLoading,
    String? currentOtp,
    int? remainingTime,
    bool? canResend,
    String? email,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      currentOtp: currentOtp ?? this.currentOtp,
      remainingTime: remainingTime ?? this.remainingTime,
      canResend: canResend ?? this.canResend,
      email: email ?? this.email,
    );
  }
}

// Provider cho register state
final registerStateProvider =
    StateNotifierProvider<RegisterStateNotifier, RegisterState>((ref) {
      return RegisterStateNotifier(ref);
    });

class RegisterStateNotifier extends StateNotifier<RegisterState> {
  final Ref ref;
  final Debouncer _countdownDebouncer = Debouncer();

  RegisterStateNotifier(this.ref) : super(const RegisterState());

  // Gửi OTP
  Future<void> sendOtp(String email, BuildContext context) async {
    state = state.copyWith(isLoading: true, email: email);

    await ref
        .read(authProvider.notifier)
        .sendOtp(email: email, purpose: 'activeAccount');

    final authState = ref.read(authProvider);

    if (authState.isOtpSent && authState.failure == null) {
      state = state.copyWith(
        isLoading: false,
        currentStep: RegisterStep.verifyOtp,
        remainingTime: 300, // 5 phút = 300 giây
        canResend: false,
      );
      _startCountdown();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // Xác thực OTP
  Future<void> verifyOtp(String otp, BuildContext context) async {
    if (otp.length == 6) {
      state = state.copyWith(isLoading: true);

      await ref
          .read(authProvider.notifier)
          .verifyOtp(email: state.email, otp: otp, purpose: 'activeAccount');

      final authState = ref.read(authProvider);

      if (authState.isOtpVerified && authState.verifyToken != null) {
        state = state.copyWith(
          isLoading: false,
          currentStep: RegisterStep.enterDetails,
        );
      } else {
        state = state.copyWith(isLoading: false);
        updateOtp('');
      }
    }
  }

  // Hoàn tất đăng ký
  Future<void> completeSignup({
    required String fullName,
    required String password,
    required String phoneNumber,
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
        .signup(
          email: state.email,
          fullName: fullName,
          password: password,
          phoneNumber: phoneNumber,
          rePassword: rePassword,
          verifyToken: verifyToken,
        );

    final newAuthState = ref.read(authProvider);

    state = state.copyWith(isLoading: false);

    if (newAuthState.failure == null) {
      // Thay vì chuyển đến login, chúng ta sẽ tự động đăng nhập
      await _autoLoginAfterSignup(context, state.email, password);
    }
  }

  Future<void> _autoLoginAfterSignup(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Gọi login với thông tin vừa đăng ký
      await ref
          .read(authProvider.notifier)
          .login(email: email, password: password);

      final authState = ref.read(authProvider);

      if (authState.isLoggedIn && authState.user != null) {
        // Đăng nhập thành công, chuyển đến màn hình chính
        if (context.mounted) {
          context.goNamed(RouteNames.home);
        }
      }
    } catch (e) {
      // Nếu có lỗi khi đăng nhập tự động, vẫn chuyển đến màn hình login
      if (context.mounted) {
        context.goNamed(
          RouteNames.login,
          extra: {'email': state.email, 'password': password},
        );
      }
    }
  }

  void _startCountdown() {
    // Hủy debouncer cũ nếu có
    _countdownDebouncer.cancel();

    _countdownDebouncer.debounce(
      duration: const Duration(seconds: 1),
      onDebounce: () {
        _runCountdown();
      },
    );
  }

  void _runCountdown() {
    if (state.remainingTime > 0) {
      state = state.copyWith(remainingTime: state.remainingTime - 1);

      // Tiếp tục countdown
      _countdownDebouncer.debounce(
        duration: const Duration(seconds: 1),
        onDebounce: () {
          _runCountdown();
        },
      );
    } else {
      state = state.copyWith(canResend: true);
      _countdownDebouncer.cancel();
    }
  }

  void updateOtp(String otp) {
    state = state.copyWith(currentOtp: otp);
  }

  void resendOtp(BuildContext context) {
    if (state.canResend) {
      // Reset debouncer khi gửi lại
      _countdownDebouncer.cancel();
      sendOtp(state.email, context);
    }
  }

  void goBackToEmail() {
    // Hủy debouncer khi quay lại
    _countdownDebouncer.cancel();

    state = state.copyWith(
      currentStep: RegisterStep.enterEmail,
      currentOtp: '',
      remainingTime: 300,
      canResend: false,
    );

    // Clear auth provider OTP states
    ref.read(authProvider.notifier).resetOtpStates();
  }

  void reset() {
    // Hủy debouncer khi reset
    _countdownDebouncer.cancel();

    state = const RegisterState();
    ref.read(authProvider.notifier).resetOtpStates();
  }

  @override
  void dispose() {
    // Hủy debouncer khi dispose
    _countdownDebouncer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Provider for password strength state
final passwordStrengthProvider = StateProvider.autoDispose<PasswordStrength>((
  ref,
) {
  return PasswordStrength();
});

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerStateProvider);
    final registerNotifier = ref.read(registerStateProvider.notifier);
    final authState = ref.watch(authProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Reset state khi dispose
    useEffect(() {
      return () {
        registerNotifier.reset();
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
      switch (registerState.currentStep) {
        case RegisterStep.enterEmail:
          return 'Đăng ký';
        case RegisterStep.verifyOtp:
          return 'Nhập mã OTP';
        case RegisterStep.enterDetails:
          return 'Hoàn tất đăng ký';
      }
    }

    String getSubtitle() {
      switch (registerState.currentStep) {
        case RegisterStep.enterEmail:
          return 'Nhập email để bắt đầu đăng ký';
        case RegisterStep.verifyOtp:
          return 'Nhập mã OTP được gửi đến email của bạn';
        case RegisterStep.enterDetails:
          return 'Nhập thông tin chi tiết để hoàn tất đăng ký';
      }
    }

    IconData getIcon() {
      switch (registerState.currentStep) {
        case RegisterStep.enterEmail:
          return Icons.person_add_outlined;
        case RegisterStep.verifyOtp:
          return Icons.security_outlined;
        case RegisterStep.enterDetails:
          return Icons.edit_outlined;
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
        // onBackPressed: registerState.currentStep == RegisterStep.enterDetails
        //     ? () => registerNotifier.goBackToEmail()
        //     : null,
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
                      registerState,
                      registerNotifier,
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
    RegisterState registerState,
    RegisterStateNotifier registerNotifier,
  ) {
    switch (registerState.currentStep) {
      case RegisterStep.enterEmail:
        return _EmailStepContent(
          registerState: registerState,
          registerNotifier: registerNotifier,
        );
      case RegisterStep.verifyOtp:
        return _OtpStepContent(
          registerState: registerState,
          registerNotifier: registerNotifier,
        );
      case RegisterStep.enterDetails:
        return _DetailsStepContent(
          registerState: registerState,
          registerNotifier: registerNotifier,
        );
    }
  }
}

// Widget cho bước nhập email
class _EmailStepContent extends HookConsumerWidget {
  final RegisterState registerState;
  final RegisterStateNotifier registerNotifier;

  const _EmailStepContent({
    required this.registerState,
    required this.registerNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    void handleSendOtp() async {
      if (formKey.currentState!.validate()) {
        await registerNotifier.sendOtp(emailController.text, context);
      }
    }

    void handleLogin() {
      context.goNamed('login');
    }

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Mô tả
          InfoCard(
            icon: Icons.info_outline,
            title: '',
            content:
                'Nhập địa chỉ email để đăng ký tài khoản. Chúng tôi sẽ gửi mã OTP qua email của bạn để xác thực.',
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Email input
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Email',
              hint: 'Nhập email của bạn',
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
              onPressed: registerState.isLoading ? null : handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  registerState.isLoading
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

          // Link đăng nhập
          AuthLink(
            question: 'Đã có tài khoản? ',
            linkText: 'Đăng nhập',
            onTap: handleLogin,
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }
}

// Widget cho bước xác thực OTP
class _OtpStepContent extends HookConsumerWidget {
  final RegisterState registerState;
  final RegisterStateNotifier registerNotifier;

  const _OtpStepContent({
    required this.registerState,
    required this.registerNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Clear OTP controller khi OTP được reset
    useEffect(() {
      if (registerState.currentOtp.isEmpty) {
        otpController.clear();
      }
      return null;
    }, [registerState.currentOtp]);

    void handleVerifyOtp() async {
      await registerNotifier.verifyOtp(registerState.currentOtp, context);
    }

    void handleResendOtp() {
      registerNotifier.resendOtp(context);
    }

    void handleBackToLogin() {
      context.goNamed('login');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Email info
        EmailInfoCard(email: registerState.email),

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
            registerNotifier.updateOtp(value);
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
              registerState.canResend
                  ? 'Có thể gửi lại mã'
                  : 'Gửi lại sau: ${registerNotifier.formatTime(registerState.remainingTime)}',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            GestureDetector(
              onTap: registerState.canResend ? handleResendOtp : null,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  color:
                      registerState.canResend
                          ? colorScheme.primary
                          : theme.disabledColor,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  decoration:
                      registerState.canResend ? TextDecoration.underline : null,
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
                (registerState.isLoading ||
                        registerState.currentOtp.length != 6)
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
                registerState.isLoading
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
          question: 'Đã có tài khoản? ',
          linkText: 'Đăng nhập',
          onTap: handleBackToLogin,
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}

// Widget cho bước nhập thông tin chi tiết
class _DetailsStepContent extends HookConsumerWidget {
  final RegisterState registerState;
  final RegisterStateNotifier registerNotifier;

  const _DetailsStepContent({
    required this.registerState,
    required this.registerNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Text controllers
    final fullNameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Visibility states
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Watch password strength
    final passwordStrength = ref.watch(passwordStrengthProvider);

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
      ref.read(passwordStrengthProvider.notifier).state = newStrength;
    }

    // Complete signup handler
    Future<void> handleCompleteSignup() async {
      if (formKey.currentState!.validate() && passwordStrength.isStrong) {
        await registerNotifier.completeSignup(
          fullName: fullNameController.text.trim(),
          password: passwordController.text,
          phoneNumber: phoneController.text.trim(),
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
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Email info (read-only)
          InfoCard(
            icon: Icons.email_outlined,
            title: 'Email đã xác thực:',
            content: registerState.email,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Họ và tên
          TextFormField(
            controller: fullNameController,
            textCapitalization: TextCapitalization.words,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: CustomInputDecoration.build(
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

          // Số điện thoại
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: CustomInputDecoration.build(
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
            controller: passwordController,
            obscureText: !isPasswordVisible.value,
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
                onPressed: () {
                  isPasswordVisible.value = !isPasswordVisible.value;
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
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

          // Xác nhận mật khẩu
          TextFormField(
            controller: confirmPasswordController,
            obscureText: !isConfirmPasswordVisible.value,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu của bạn',
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
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => handleCompleteSignup(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Security tips
          // Security tips
          InfoCard(
            icon: Icons.security_outlined,
            title: 'Bảo mật mật khẩu:',
            content:
                'Mật khẩu mạnh bao gồm ít nhất 8 ký tự, có chữ hoa, chữ thường, số và ký tự đặc biệt.',
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Complete signup button
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed:
                  (registerState.isLoading || !passwordStrength.isStrong)
                      ? null
                      : handleCompleteSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  registerState.isLoading
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
                        'Hoàn tất đăng ký',
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
            question: 'Đã có tài khoản? ',
            linkText: 'Đăng nhập',
            onTap: () => context.goNamed('login'),
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }
}
