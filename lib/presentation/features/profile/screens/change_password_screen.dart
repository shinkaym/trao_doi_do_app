import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/password_header_widget.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/security_info_widget.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/change_password/security_tips_widget.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/password_strength_widget.dart';

class ChangePasswordScreen extends HookConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Text editing controllers using hooks
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    
    // Focus nodes using hooks
    final currentPasswordFocusNode = useFocusNode();
    final newPasswordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();

    // Form key using hooks
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // State variables using hooks
    final isCurrentPasswordVisible = useState(false);
    final isNewPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);
    final isLoading = useState(false);

    // Password strength indicators using hooks
    final hasMinLength = useState(false);
    final hasUppercase = useState(false);
    final hasLowercase = useState(false);
    final hasNumbers = useState(false);
    final hasSpecialChar = useState(false);

    // Memoized password strength calculations
    final isPasswordStrong = useMemoized(
      () => hasMinLength.value &&
          hasUppercase.value &&
          hasLowercase.value &&
          hasNumbers.value &&
          hasSpecialChar.value,
      [
        hasMinLength.value,
        hasUppercase.value,
        hasLowercase.value,
        hasNumbers.value,
        hasSpecialChar.value,
      ],
    );

    // Password strength checking function
    void checkPasswordStrength(String password) {
      hasMinLength.value = password.length >= 8;
      hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
      hasLowercase.value = password.contains(RegExp(r'[a-z]'));
      hasNumbers.value = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    }

    // Handle password change function
    Future<void> handleChangePassword() async {
      if (formKey.currentState!.validate() && isPasswordStrong) {
        isLoading.value = true;

        try {
          // Giả lập API call thay đổi mật khẩu
          await Future.delayed(const Duration(seconds: 2));

          if (context.mounted) {
            context.showSuccessSnackBar('Đổi mật khẩu thành công!');

            // Xóa form sau khi thành công
            currentPasswordController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();

            // Reset password strength indicators
            hasMinLength.value = false;
            hasUppercase.value = false;
            hasLowercase.value = false;
            hasNumbers.value = false;
            hasSpecialChar.value = false;

            // Quay lại màn hình trước đó
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            context.showErrorSnackBar('Lỗi khi đổi mật khẩu: $e');
          }
        } finally {
          if (context.mounted) {
            isLoading.value = false;
          }
        }
      }
    }

    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // Sử dụng CustomAppBar giống như EditProfileScreen
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        notificationCount: 3, // Có thể truyền số thông báo từ state management
        onNotificationTap: () {
          // Xử lý khi tap vào notification
          context.pushNamed('notifications');
        },
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              const PasswordHeaderWidget(),
              // Form Section
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isTablet ? 32 : 24),

                        // Thông tin bảo mật
                        const SecurityInfoWidget(),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Mật khẩu hiện tại
                        TextFormField(
                          controller: currentPasswordController,
                          focusNode: currentPasswordFocusNode,
                          enabled: !isLoading.value,
                          obscureText: !isCurrentPasswordVisible.value,
                          decoration: CustomInputDecoration.build(
                            context,
                            label: 'Mật khẩu hiện tại',
                            hint: 'Nhập mật khẩu hiện tại',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                isCurrentPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                              onPressed: () {
                                isCurrentPasswordVisible.value = 
                                    !isCurrentPasswordVisible.value;
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => newPasswordFocusNode.requestFocus(),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Mật khẩu mới
                        TextFormField(
                          controller: newPasswordController,
                          focusNode: newPasswordFocusNode,
                          enabled: !isLoading.value,
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
                                isNewPasswordVisible.value = 
                                    !isNewPasswordVisible.value;
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (value == currentPasswordController.text) {
                              return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                            }
                            if (!isPasswordStrong) {
                              return 'Mật khẩu chưa đủ mạnh';
                            }
                            return null;
                          },
                          onChanged: checkPasswordStrength,
                          onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),

                        // Password strength indicator
                        if (newPasswordController.text.isNotEmpty) ...[
                          PasswordStrengthWidget(
                            password: newPasswordController.text,
                            hasMinLength: hasMinLength.value,
                            hasUppercase: hasUppercase.value,
                            hasLowercase: hasLowercase.value,
                            hasNumbers: hasNumbers.value,
                            hasSpecialChar: hasSpecialChar.value,
                          ),
                          SizedBox(height: isTablet ? 24 : 20),
                        ],

                        // Xác nhận mật khẩu mới
                        TextFormField(
                          controller: confirmPasswordController,
                          focusNode: confirmPasswordFocusNode,
                          enabled: !isLoading.value,
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
                          onFieldSubmitted: (_) => handleChangePassword(),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Lời khuyên bảo mật
                        const SecurityTipsWidget(),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Nút đổi mật khẩu
                        SizedBox(
                          height: isTablet ? 56 : 50,
                          child: ElevatedButton.icon(
                            onPressed: (isLoading.value || !isPasswordStrong)
                                ? null
                                : handleChangePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: isLoading.value
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
                                : const Icon(Icons.security),
                            label: Text(
                              isLoading.value ? 'Đang cập nhật...' : 'Đổi mật khẩu',
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}