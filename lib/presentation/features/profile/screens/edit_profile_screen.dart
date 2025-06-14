import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/edit_profile/avatar_section.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';
import 'dart:io';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks for form controllers
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final majorController = useTextEditingController();

    // Hooks for state management
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final selectedImage = useState<File?>(null);
    final picker = useMemoized(() => ImagePicker());

    // Watch auth state to get user data
    final authState = ref.watch(authProvider);

    // Initialize controllers with user data
    useEffect(() {
      if (authState.user != null) {
        nameController.text = authState.user!.fullName;
        phoneController.text = authState.user!.phoneNumber;
        majorController.text = authState.user!.major;
      }
      return null;
    }, [authState.user]);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.successMessage != null) {
        context.showSuccessSnackBar(next.successMessage!);
        // Clear success message and navigate back
        Future.microtask(() {
          ref.read(authProvider.notifier).clearSuccess();
          context.pop();
        });
      }

      if (next.failure != null) {
        context.showErrorSnackBar(next.failure!.message);
        // Clear error after showing
        Future.microtask(() => ref.read(authProvider.notifier).clearError());
      }
    });

    Future<void> pickImage() async {
      try {
        await context.showAppBottomSheet(
          child: ImagePickerBottomSheet(
            title: 'Chọn ảnh đại diện',
            picker: picker,
            onImageSelected: (image) {
              selectedImage.value = image;
            },
          ),
        );
      } catch (e) {
        context.showErrorSnackBar('Lỗi khi chọn ảnh: $e');
      }
    }

    Future<void> handleSave() async {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;

        try {
          // Call the auth provider to update profile
          // await ref.read(authProvider.notifier).updateProfile(
          //   fullName: nameController.text.trim(),
          //   phoneNumber: phoneController.text.trim(),
          //   major: majorController.text.trim(),
          //   avatarFile: selectedImage.value,
          // );
        } catch (e) {
          context.showErrorSnackBar('Lỗi khi cập nhật: $e');
        } finally {
          isLoading.value = false;
        }
      }
    }

    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    return SmartScaffold(
      title: 'Chỉnh sửa thông tin',
      appBarType: AppBarType.standard,
      showBackButton: true,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AvatarSection(
                selectedImage: selectedImage.value,
                currentAvatarUrl: authState.user?.avatar ?? '',
                onPickImage: pickImage,
              ),
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

                        // Show loading indicator if auth operation is in progress
                        if (authState.isLoading) ...[
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                        ],

                        TextFormField(
                          controller: nameController,
                          enabled: !authState.isLoading && !isLoading.value,
                          decoration: CustomInputDecoration.build(
                            context,
                            label: 'Họ và tên',
                            hint: 'Nhập họ và tên của bạn',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            if (value.trim().length < 2) {
                              return 'Họ và tên phải có ít nhất 2 ký tự';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        TextFormField(
                          initialValue: authState.user?.email ?? '',
                          enabled: false,
                          decoration: CustomInputDecoration.buildDisabled(
                            context,
                            label: 'Email',
                            hint: 'Email không thể thay đổi',
                            icon: Icons.email_outlined,
                            suffix: const Icon(Icons.lock_outline, size: 20),
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        TextFormField(
                          controller: phoneController,
                          enabled: !authState.isLoading && !isLoading.value,
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
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(
                              r'^0[0-9]{9,10}$',
                            ).hasMatch(value.trim())) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        TextFormField(
                          controller: majorController,
                          enabled: !authState.isLoading && !isLoading.value,
                          decoration: CustomInputDecoration.build(
                            context,
                            label: 'Ngành học',
                            hint: 'Nhập ngành học của bạn',
                            icon: Icons.school_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập ngành học';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 40 : 32),

                        SizedBox(
                          height: isTablet ? 56 : 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                (authState.isLoading || isLoading.value)
                                    ? null
                                    : handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon:
                                (authState.isLoading || isLoading.value)
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Icon(Icons.save),
                            label: Text(
                              (authState.isLoading || isLoading.value)
                                  ? 'Đang lưu...'
                                  : 'Lưu thay đổi',
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
