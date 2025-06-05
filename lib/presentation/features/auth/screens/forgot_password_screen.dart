import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header_widget.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/auth_divider_widget.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/info_card_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// State model cho forgot password
class ForgotPasswordState {
  final bool isLoading;
  final bool isEmailSent;
  final bool isOtpLoading;
  final String currentOtp;
  final int remainingTime;
  final bool canResend;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isEmailSent = false,
    this.isOtpLoading = false,
    this.currentOtp = '',
    this.remainingTime = 300,
    this.canResend = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isEmailSent,
    bool? isOtpLoading,
    String? currentOtp,
    int? remainingTime,
    bool? canResend,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isEmailSent: isEmailSent ?? this.isEmailSent,
      isOtpLoading: isOtpLoading ?? this.isOtpLoading,
      currentOtp: currentOtp ?? this.currentOtp,
      remainingTime: remainingTime ?? this.remainingTime,
      canResend: canResend ?? this.canResend,
    );
  }
}

// Provider cho forgot password state
final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
      return ForgotPasswordNotifier();
    });

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordState());

  Future<void> sendOtpRequest(String email, BuildContext context) async {
    state = state.copyWith(isLoading: true);

    // Giả lập gửi yêu cầu
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      isLoading: false,
      isEmailSent: true,
      remainingTime: 300,
      canResend: false,
    );

    // Hiển thị thông báo thành công
    context.showSuccessSnackBar('OTP đã được gửi đến $email');

    // Bắt đầu đếm ngược
    _startCountdown();
  }

  void _startCountdown() {
    if (state.remainingTime > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (state.remainingTime > 0) {
          state = state.copyWith(remainingTime: state.remainingTime - 1);
          _startCountdown();
        } else {
          state = state.copyWith(canResend: true);
        }
      });
    }
  }

  Future<void> verifyOtp(String otp, String email, BuildContext context) async {
    if (otp.length == 6) {
      state = state.copyWith(isOtpLoading: true);

      // Giả lập xác thực OTP
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isOtpLoading: false);

      // Giả lập OTP đúng (trong thực tế sẽ gọi API)
      if (otp == '123456') {
        // OTP đúng - chuyển đến màn hình đặt lại mật khẩu
        context.showSuccessSnackBar('OTP xác thực thành công!');
        context.goNamed('reset-password', extra: email);
      } else {
        // OTP sai
        context.showErrorSnackBar('OTP không chính xác. Vui lòng thử lại.');
        updateOtp('');
      }
    }
  }

  void updateOtp(String otp) {
    state = state.copyWith(currentOtp: otp);
  }

  void resendOtp(String email, BuildContext context) {
    if (state.canResend) {
      sendOtpRequest(email, context);
    }
  }

  void reset() {
    state = const ForgotPasswordState();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final otpController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Reset state khi dispose
    useEffect(() {
      return () {
        forgotPasswordNotifier.reset();
      };
    }, []);

    // Clear OTP controller khi OTP được reset
    useEffect(() {
      if (forgotPasswordState.currentOtp.isEmpty) {
        otpController.clear();
      }

      return null;
    }, [forgotPasswordState.currentOtp]);

    void handleSendRequest() async {
      if (formKey.currentState!.validate()) {
        await forgotPasswordNotifier.sendOtpRequest(
          emailController.text,
          context,
        );
      }
    }

    void handleVerifyOtp() async {
      await forgotPasswordNotifier.verifyOtp(
        forgotPasswordState.currentOtp,
        emailController.text,
        context,
      );
    }

    void handleBackToLogin() {
      context.goNamed('login');
    }

    void handleResendOtp() {
      forgotPasswordNotifier.resendOtp(emailController.text, context);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: SmartScaffold(
        title:
            forgotPasswordState.isEmailSent ? 'Nhập mã OTP' : 'Quên mật khẩu',
        appBarType: AppBarType.minimal,
        showBackButton: true,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppHeaderWidget(
                  title:
                      forgotPasswordState.isEmailSent
                          ? 'Nhập mã OTP'
                          : 'Quên mật khẩu',
                  subtitle:
                      forgotPasswordState.isEmailSent
                          ? 'Nhập mã OTP được gửi đến email của bạn'
                          : 'Nhập email để đặt lại mật khẩu',
                  icon:
                      forgotPasswordState.isEmailSent
                          ? Icons.security_outlined
                          : Icons.lock_reset_outlined,
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child:
                        forgotPasswordState.isEmailSent
                            ? _buildOtpContent(
                              context,
                              ref,
                              otpController,
                              emailController.text,
                              forgotPasswordState,
                              forgotPasswordNotifier,
                              handleVerifyOtp,
                              handleResendOtp,
                              handleBackToLogin,
                            )
                            : _buildFormContent(
                              context,
                              formKey,
                              emailController,
                              forgotPasswordState,
                              handleSendRequest,
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
    TextEditingController emailController,
    ForgotPasswordState state,
    VoidCallback onSendRequest,
    VoidCallback onBackToLogin,
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

          // Mô tả
          InfoCardWidget(
            icon: Icons.info_outline,
            title: '',
            content:
                'Nhập địa chỉ email đã đăng ký. Chúng tôi sẽ gửi mã OTP qua email của bạn.',
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Email input
          TextFormField(
            controller: emailController,
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
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onFieldSubmitted: (_) => onSendRequest(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Nút gửi yêu cầu
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : onSendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  state.isLoading
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
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'hoặc',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Link về đăng nhập
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nhớ mật khẩu? ',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              GestureDetector(
                onTap: onBackToLogin,
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

  Widget _buildOtpContent(
    BuildContext context,
    WidgetRef ref,
    TextEditingController otpController,
    String email,
    ForgotPasswordState state,
    ForgotPasswordNotifier notifier,
    VoidCallback onVerifyOtp,
    VoidCallback onResendOtp,
    VoidCallback onBackToLogin,
  ) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Email info
        EmailInfoCard(email: email),

        SizedBox(height: isTablet ? 32 : 24),

        // OTP Input
        Text(
          'Nhập mã OTP (6 chữ số)',
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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            notifier.updateOtp(value);
          },
          onCompleted: (value) {
            onVerifyOtp();
          },
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Timer and resend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.canResend
                  ? 'Có thể gửi lại mã'
                  : 'Gửi lại sau: ${notifier.formatTime(state.remainingTime)}',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            GestureDetector(
              onTap: state.canResend ? onResendOtp : null,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  color:
                      state.canResend
                          ? colorScheme.primary
                          : theme.disabledColor,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  decoration: state.canResend ? TextDecoration.underline : null,
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
                (state.isOtpLoading || state.currentOtp.length != 6)
                    ? null
                    : onVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                state.isOtpLoading
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

        // Help text
        const AuthDividerWidget(),
        SizedBox(height: isTablet ? 32 : 24),

        // Back to login
        AuthLinkWidget(
          question: 'Nhớ mật khẩu? ',
          linkText: 'Đăng nhập',
          onTap: onBackToLogin,
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final theme = context.theme;

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

// Widget helper cho email info (giả sử đã có sẵn)
class EmailInfoCard extends StatelessWidget {
  final String email;

  const EmailInfoCard({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: context.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mã OTP đã được gửi đến:\n$email',
              style: TextStyle(fontSize: 14, color: context.theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper cho auth link (giả sử đã có sẵn)
class AuthLinkWidget extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkWidget({
    super.key,
    required this.question,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
