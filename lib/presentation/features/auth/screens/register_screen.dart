import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/app_header_widget.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/auth_divider_widget.dart';
import 'package:trao_doi_do_app/presentation/features/auth/widgets/info_card_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

// Provider for password strength state
final passwordStrengthProvider = StateProvider.autoDispose<PasswordStrength>((
  ref,
) {
  return PasswordStrength();
});

// Provider for loading state
final registerLoadingProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

// Password strength data class
class PasswordStrength {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSpecialChar;

  const PasswordStrength({
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
    this.hasNumbers = false,
    this.hasSpecialChar = false,
  });

  bool get isStrong {
    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumbers &&
        hasSpecialChar;
  }

  PasswordStrength copyWith({
    bool? hasMinLength,
    bool? hasUppercase,
    bool? hasLowercase,
    bool? hasNumbers,
    bool? hasSpecialChar,
  }) {
    return PasswordStrength(
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
      hasNumbers: hasNumbers ?? this.hasNumbers,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
    );
  }
}

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Text controllers
    final fullNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Visibility states
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Watch providers
    final passwordStrength = ref.watch(passwordStrengthProvider);
    final isLoading = ref.watch(registerLoadingProvider);

    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

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

    // Register handler
    Future<void> handleRegister() async {
      if (formKey.currentState!.validate() && passwordStrength.isStrong) {
        ref.read(registerLoadingProvider.notifier).state = true;

        try {
          await Future.delayed(const Duration(seconds: 2));

          if (context.mounted) {
            context.showSuccessSnackBar('Đăng ký thành công!');

            // Wait 1 second then navigate
            await Future.delayed(const Duration(seconds: 1));

            if (context.mounted) {
              context.goNamed('login');
            }
          }
        } finally {
          ref.read(registerLoadingProvider.notifier).state = false;
        }
      }
    }

    // Login handler
    void handleLogin() {
      context.goNamed('login');
    }

    // Listen to password changes
    useEffect(() {
      void listener() {
        checkPasswordStrength(passwordController.text);
      }

      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, [passwordController]);

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
                  title: 'Đăng ký',
                  subtitle: 'Tạo tài khoản mới',
                  icon: Icons.person_add_outlined,
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

                          // Họ và tên
                          TextFormField(
                            controller: fullNameController,
                            textCapitalization: TextCapitalization.words,
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

                          // Email
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
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                                  isPasswordVisible.value =
                                      !isPasswordVisible.value;
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
                            onFieldSubmitted: (_) => handleRegister(),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Security tips
                          InfoCardWidget(
                            icon: Icons.security_outlined,
                            title: 'Lời khuyên bảo mật:',
                            content:
                                '• Không chia sẻ mật khẩu với người khác\n'
                                '• Thay đổi mật khẩu định kỳ để đảm bảo bảo mật',
                            backgroundColor: context.colorScheme.surfaceVariant
                                .withOpacity(0.3),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Nút đăng ký
                          SizedBox(
                            height: isTablet ? 56 : 50,
                            child: ElevatedButton(
                              onPressed:
                                  (isLoading || !passwordStrength.isStrong)
                                      ? null
                                      : handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  isLoading
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
                          const AuthDividerWidget(),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Link đăng nhập
                          AuthLinkWidget(
                            question: 'Đã có tài khoản? ',
                            linkText: 'Đăng nhập',
                            onTap: handleLogin,
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

// AuthLinkWidget - assuming it exists or you can create it
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
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Center(
      child: RichText(
        text: TextSpan(
          text: question,
          style: textTheme.bodyMedium,
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  linkText,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
