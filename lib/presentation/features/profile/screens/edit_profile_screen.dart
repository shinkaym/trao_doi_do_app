import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/edit_profile/avatar_section.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/edit_profile/image_picker_bottom_sheet.dart';
import 'dart:io';
import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _majorController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _currentUserData = {
    'name': 'Nguyễn Văn An',
    'email': 'nguyenvanan@email.com',
    'phone': '0909691405',
    'major': 'Công nghệ thông tin',
    'avatar': '',
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = _currentUserData['name'] ?? '';
    _phoneController.text = _currentUserData['phone'] ?? '';
    _majorController.text = _currentUserData['major'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      await context.showAppBottomSheet(
        child: ImagePickerBottomSheet(
          picker: _picker,
          onImageSelected: (image) {
            setState(() {
              _selectedImage = image;
            });
          },
        ),
      );
    } catch (e) {
      context.showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.showSuccessSnackBar('Cập nhật thông tin thành công');
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('Lỗi khi cập nhật: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Chỉnh sửa thông tin',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        notificationCount: 3,
        onNotificationTap: () => context.pushNamed('notifications'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AvatarSection(
                selectedImage: _selectedImage,
                currentAvatarUrl: _currentUserData['avatar'] ?? '',
                onPickImage: _pickImage,
              ),
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isTablet ? 32 : 24),
                        TextFormField(
                          controller: _nameController,
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
                          initialValue: _currentUserData['email'],
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
                          controller: _phoneController,
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
                          controller: _majorController,
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
                            onPressed: _isLoading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon:
                                _isLoading
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
                              _isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
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
