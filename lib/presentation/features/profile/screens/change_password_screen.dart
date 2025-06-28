import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/email_info_card.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/info_card.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/password_header_widget.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/security_info_widget.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/security_tips_widget.dart';
import 'package:trao_doi_do_app/presentation/models/password_strength.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_divider.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// Enum để quản lý các bước đổi mật khẩu
enum ChangePasswordStep {
  enterPasswords, // Bước 1: Nhập mật khẩu mới và xác nhận
  verifyOtp, // Bước 2: Xác thực OTP
}

// State model cho change password
class ChangePasswordState {
  final ChangePasswordStep currentStep;
  final bool isLoading;
  final String currentOtp;
  final int remainingTime;
  final bool canResend;
  final String email;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordState({
    this.currentStep = ChangePasswordStep.enterPasswords,
    this.isLoading = false,
    this.currentOtp = '',
    this.remainingTime = 300,
    this.canResend = false,
    this.email = '',
    this.newPassword = '',
    this.confirmPassword = '',
  });

  ChangePasswordState copyWith({
    ChangePasswordStep? currentStep,
    bool? isLoading,
    String? currentOtp,
    int? remainingTime,
    bool? canResend,
    String? email,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ChangePasswordState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      currentOtp: currentOtp ?? this.currentOtp,
      remainingTime: remainingTime ?? this.remainingTime,
      canResend: canResend ?? this.canResend,
      email: email ?? this.email,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

// Provider cho change password state
final changePasswordStateProvider =
    StateNotifierProvider<ChangePasswordStateNotifier, ChangePasswordState>((
      ref,
    ) {
      return ChangePasswordStateNotifier(ref);
    });

class ChangePasswordStateNotifier extends StateNotifier<ChangePasswordState> {
  final Ref ref;
  Timer? _countdownTimer;

  ChangePasswordStateNotifier(this.ref) : super(const ChangePasswordState());

  // Gửi OTP cho đổi mật khẩu
  Future<void> sendOtpForPasswordChange({
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    // Lấy email từ user hiện tại
    final authState = ref.read(authProvider);
    final userEmail = authState.user?.email;

    if (userEmail == null) {
      if (context.mounted) {
        context.showErrorSnackBar('Không tìm thấy thông tin người dùng');
      }
      return;
    }

    state = state.copyWith(
      isLoading: true,
      email: userEmail,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    await ref
        .read(authProvider.notifier)
        .sendOtp(email: userEmail, purpose: 'resetPassword');

    final newAuthState = ref.read(authProvider);

    if (newAuthState.isOtpSent && newAuthState.failure == null) {
      state = state.copyWith(
        isLoading: false,
        currentStep: ChangePasswordStep.verifyOtp,
        remainingTime: 300, // 5 phút = 300 giây
        canResend: false,
      );
      _startCountdown();

      if (context.mounted) {
        context.showSuccessSnackBar('OTP đã được gửi đến $userEmail');
      }
    } else {
      state = state.copyWith(isLoading: false);

      if (context.mounted) {
        context.showErrorSnackBar(newAuthState.failure!.message);
      }
    }
  }

  // Xác thực OTP cho đổi mật khẩu
  Future<void> verifyOtp(String otp, BuildContext context) async {
    if (otp.length == 6) {
      state = state.copyWith(isLoading: true);

      await ref
          .read(authProvider.notifier)
          .verifyOtp(email: state.email, otp: otp, purpose: 'resetPassword');

      final authState = ref.read(authProvider);

      if (authState.isOtpVerified && authState.verifyToken != null) {
        // OTP xác thực thành công, tiến hành đổi mật khẩu
        await _completePasswordChange(authState.verifyToken!, context);
      } else {
        state = state.copyWith(isLoading: false);
        updateOtp('');

        if (context.mounted) {
          context.showErrorSnackBar(authState.failure!.message);
        }
      }
    }
  }

  // Hoàn tất đổi mật khẩu
  Future<void> _completePasswordChange(
    String verifyToken,
    BuildContext context,
  ) async {
    await ref
        .read(authProvider.notifier)
        .resetPassword(
          email: state.email,
          password: state.newPassword,
          rePassword: state.confirmPassword,
          verifyToken: verifyToken,
        );

    final authState = ref.read(authProvider);

    state = state.copyWith(isLoading: false);

    if (authState.failure == null) {
      if (context.mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          // Quay lại màn hình trước đó
          context.pop();
        }
      }
    } else {
      if (context.mounted) {
        context.showErrorSnackBar(authState.failure!.message);
      }
    }
  }

  void _startCountdown() {
    // Hủy timer cũ nếu có
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime > 0) {
        state = state.copyWith(remainingTime: state.remainingTime - 1);
      } else {
        state = state.copyWith(canResend: true);
        timer.cancel();
        _countdownTimer = null;
      }
    });
  }

  void updateOtp(String otp) {
    state = state.copyWith(currentOtp: otp);
  }

  void resendOtp(BuildContext context) {
    if (state.canResend) {
      // Reset timer khi gửi lại
      _countdownTimer?.cancel();
      _sendOtpAgain(context);
    }
  }

  Future<void> _sendOtpAgain(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    await ref
        .read(authProvider.notifier)
        .sendOtp(email: state.email, purpose: 'resetPassword');

    final authState = ref.read(authProvider);

    if (authState.isOtpSent && authState.failure == null) {
      state = state.copyWith(
        isLoading: false,
        remainingTime: 300,
        canResend: false,
      );
      _startCountdown();

      if (context.mounted) {
        context.showSuccessSnackBar('OTP đã được gửi lại đến ${state.email}');
      }
    } else {
      state = state.copyWith(isLoading: false);

      if (context.mounted) {
        context.showErrorSnackBar(authState.failure!.message);
      }
    }
  }

  void goBackToPasswordInput() {
    // Hủy timer khi quay lại
    _countdownTimer?.cancel();
    _countdownTimer = null;

    state = state.copyWith(
      currentStep: ChangePasswordStep.enterPasswords,
      currentOtp: '',
      remainingTime: 300,
      canResend: false,
    );

    // Clear auth provider OTP states
    ref.read(authProvider.notifier).resetOtpStates();
  }

  void reset() {
    // Hủy timer khi reset
    _countdownTimer?.cancel();
    _countdownTimer = null;

    state = const ChangePasswordState();
    ref.read(authProvider.notifier).resetOtpStates();
  }

  @override
  void dispose() {
    // Hủy timer khi dispose
    _countdownTimer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Provider for password strength state trong change password
final changePasswordStrengthProvider =
    StateProvider.autoDispose<PasswordStrength>((ref) {
      return PasswordStrength();
    });

class ChangePasswordScreen extends HookConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changePasswordState = ref.watch(changePasswordStateProvider);
    final changePasswordNotifier = ref.read(
      changePasswordStateProvider.notifier,
    );
    final authState = ref.watch(authProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Reset state khi dispose
    useEffect(() {
      return () {
        changePasswordNotifier.reset();
      };
    }, []);

    // Watch for auth state changes to clear errors
    useEffect(() {
      if (authState.failure != null) {
        Future.microtask(() {
          ref.read(authProvider.notifier).clearError();
        });
      }
      return null;
    }, [authState.failure, authState.successMessage]);

    String getTitle() {
      switch (changePasswordState.currentStep) {
        case ChangePasswordStep.enterPasswords:
          return 'Đổi mật khẩu';
        case ChangePasswordStep.verifyOtp:
          return 'Xác thực OTP';
      }
    }

    String getSubtitle() {
      switch (changePasswordState.currentStep) {
        case ChangePasswordStep.enterPasswords:
          return 'Nhập mật khẩu mới để thay đổi';
        case ChangePasswordStep.verifyOtp:
          return 'Nhập mã OTP được gửi đến email của bạn';
      }
    }

    IconData getIcon() {
      switch (changePasswordState.currentStep) {
        case ChangePasswordStep.enterPasswords:
          return Icons.lock_reset_outlined;
        case ChangePasswordStep.verifyOtp:
          return Icons.security_outlined;
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
        appBarType: AppBarType.standard,
        showBackButton: true,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header chỉ hiển thị cho bước đầu tiên
                if (changePasswordState.currentStep ==
                    ChangePasswordStep.enterPasswords)
                  const PasswordHeaderWidget()
                else
                  AppHeader(
                    title: getTitle(),
                    subtitle: getSubtitle(),
                    icon: getIcon(),
                  ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600 : double.infinity,
                    ),
                    child: _buildStepContent(
                      context,
                      ref,
                      changePasswordState,
                      changePasswordNotifier,
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
    ChangePasswordState changePasswordState,
    ChangePasswordStateNotifier changePasswordNotifier,
  ) {
    switch (changePasswordState.currentStep) {
      case ChangePasswordStep.enterPasswords:
        return _PasswordInputStepContent(
          changePasswordState: changePasswordState,
          changePasswordNotifier: changePasswordNotifier,
        );
      case ChangePasswordStep.verifyOtp:
        return _OtpStepContent(
          changePasswordState: changePasswordState,
          changePasswordNotifier: changePasswordNotifier,
        );
    }
  }
}

// Widget cho bước nhập mật khẩu mới
class _PasswordInputStepContent extends HookConsumerWidget {
  final ChangePasswordState changePasswordState;
  final ChangePasswordStateNotifier changePasswordNotifier;

  const _PasswordInputStepContent({
    required this.changePasswordState,
    required this.changePasswordNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Text controllers
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Focus nodes
    final newPasswordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();

    // Visibility states
    final isNewPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Watch password strength
    final passwordStrength = ref.watch(changePasswordStrengthProvider);

    final isTablet = context.isTablet;
    final theme = context.theme;
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
      ref.read(changePasswordStrengthProvider.notifier).state = newStrength;
    }

    // Handle continue to OTP step
    Future<void> handleContinueToOtp() async {
      if (formKey.currentState!.validate() && passwordStrength.isStrong) {
        await changePasswordNotifier.sendOtpForPasswordChange(
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
          context: context,
        );
      }
    }

    // Listen to new password changes
    useEffect(() {
      void listener() {
        checkPasswordStrength(newPasswordController.text);
      }

      newPasswordController.addListener(listener);
      return () => newPasswordController.removeListener(listener);
    }, [newPasswordController]);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 32 : 24),

          // Thông tin bảo mật
          const SecurityInfoWidget(),
          SizedBox(height: isTablet ? 32 : 24),

          // Mật khẩu mới
          TextFormField(
            controller: newPasswordController,
            focusNode: newPasswordFocusNode,
            enabled: !changePasswordState.isLoading,
            obscureText: !isNewPasswordVisible.value,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
              icon: Icons.lock_reset_outlined,
              suffix: IconButton(
                icon: Icon(
                  isNewPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: theme.hintColor,
                ),
                onPressed: () {
                  isNewPasswordVisible.value = !isNewPasswordVisible.value;
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
            onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Password strength indicator
          if (newPasswordController.text.isNotEmpty) ...[
            PasswordStrengthWidget(
              password: newPasswordController.text,
              hasMinLength: passwordStrength.hasMinLength,
              hasUppercase: passwordStrength.hasUppercase,
              hasLowercase: passwordStrength.hasLowercase,
              hasNumbers: passwordStrength.hasNumbers,
              hasSpecialChar: passwordStrength.hasSpecialChar,
            ),
            SizedBox(height: isTablet ? 24 : 20),
          ],

          // Xác nhận mật khẩu mới
          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            enabled: !changePasswordState.isLoading,
            obscureText: !isConfirmPasswordVisible.value,
            decoration: CustomInputDecoration.build(
              context,
              label: 'Xác nhận mật khẩu mới',
              hint: 'Nhập lại mật khẩu mới',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  isConfirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
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
                return 'Vui lòng xác nhận mật khẩu mới';
              }
              if (value != newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => handleContinueToOtp(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Security tips
          const SecurityTipsWidget(),
          SizedBox(height: isTablet ? 32 : 24),

          // Nút tiếp tục (gửi OTP)
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton.icon(
              onPressed:
                  (changePasswordState.isLoading || !passwordStrength.isStrong)
                      ? null
                      : handleContinueToOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon:
                  changePasswordState.isLoading
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
                      : const Icon(Icons.send_outlined),
              label: Text(
                changePasswordState.isLoading
                    ? 'Đang gửi OTP...'
                    : 'Gửi mã OTP',
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
    );
  }
}

// Widget cho bước xác thực OTP
class _OtpStepContent extends HookConsumerWidget {
  final ChangePasswordState changePasswordState;
  final ChangePasswordStateNotifier changePasswordNotifier;

  const _OtpStepContent({
    required this.changePasswordState,
    required this.changePasswordNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Clear OTP controller khi OTP được reset
    useEffect(() {
      if (changePasswordState.currentOtp.isEmpty) {
        otpController.clear();
      }
      return null;
    }, [changePasswordState.currentOtp]);

    void handleVerifyOtp() async {
      await changePasswordNotifier.verifyOtp(
        changePasswordState.currentOtp,
        context,
      );
    }

    void handleResendOtp() {
      changePasswordNotifier.resendOtp(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Email info
        EmailInfoCard(email: changePasswordState.email),

        SizedBox(height: isTablet ? 24 : 20),

        // Thông báo về mật khẩu mới
        InfoCard(
          icon: Icons.info_outline,
          title: 'Mật khẩu mới đã được chuẩn bị',
          content: 'Xác thực OTP để hoàn tất việc thay đổi mật khẩu của bạn.',
          backgroundColor: colorScheme.primary.withOpacity(0.1),
        ),

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
            changePasswordNotifier.updateOtp(value);
          },
          onCompleted: (value) {
            handleVerifyOtp();
          },
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Timer and resend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              changePasswordState.canResend
                  ? 'Có thể gửi lại mã'
                  : 'Gửi lại sau: ${changePasswordNotifier.formatTime(changePasswordState.remainingTime)}',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            GestureDetector(
              onTap: changePasswordState.canResend ? handleResendOtp : null,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  color:
                      changePasswordState.canResend
                          ? colorScheme.primary
                          : theme.disabledColor,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  decoration:
                      changePasswordState.canResend
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
          child: ElevatedButton.icon(
            onPressed:
                (changePasswordState.isLoading ||
                        changePasswordState.currentOtp.length != 6)
                    ? null
                    : handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon:
                changePasswordState.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.security),
            label: Text(
              changePasswordState.isLoading
                  ? 'Đang xác thực...'
                  : 'Xác thực & Đổi mật khẩu',
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

        // Security note
        InfoCard(
          icon: Icons.security_outlined,
          title: 'Lưu ý bảo mật:',
          content:
              'Sau khi đổi mật khẩu thành công, bạn có thể cần đăng nhập lại trên các thiết bị khác.',
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}
