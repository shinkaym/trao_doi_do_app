import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

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

  // Dữ liệu user hiện tại (giả lập)
  final Map<String, String> _currentUserData = {
    'name': 'Nguyễn Văn An',
    'email': 'nguyenvanan@email.com',
    'phone': '+84 901 234 567',
    'major': 'Công nghệ thông tin',
    'avatar': '', // URL ảnh đại diện hiện tại
  };

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu hiện tại vào form
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
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          final isTablet = MediaQuery.of(context).size.width > 600;
          return Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                Text(
                  'Chọn ảnh đại diện',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Máy ảnh',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            _selectedImage = File(image.path);
                          });
                        }
                      },
                    ),
                    _buildImageSourceOption(
                      context,
                      icon: Icons.photo_library,
                      label: 'Thư viện',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            _selectedImage = File(image.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 32 : 24),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isTablet ? 120 : 100,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 20 : 16,
          horizontal: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isTablet ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Giả lập việc lưu dữ liệu
        await Future.delayed(const Duration(seconds: 2));

        // Cập nhật dữ liệu thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Quay lại màn hình profile
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // Sử dụng CustomAppBar thay vì AppBar thông thường
      appBar: CustomAppBar(
        title: 'Chỉnh sửa thông tin',
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
              // Header Section với Avatar
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
                    vertical: isTablet ? 40 : 30,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      // Avatar với khả năng chỉnh sửa
                      Stack(
                        children: [
                          Container(
                            width: isTablet ? 120 : 100,
                            height: isTablet ? 120 : 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child:
                                _selectedImage != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(57),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : (_currentUserData['avatar']!.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            57,
                                          ),
                                          child: Image.network(
                                            _currentUserData['avatar']!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.person,
                                                      size: isTablet ? 60 : 50,
                                                      color: Colors.white,
                                                    ),
                                          ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: isTablet ? 60 : 50,
                                          color: Colors.white,
                                        )),
                          ),
                          // Nút chỉnh sửa avatar
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: isTablet ? 40 : 36,
                                height: isTablet ? 40 : 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: isTablet ? 20 : 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        'Cập nhật ảnh đại diện',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Section
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

                        // Họ và tên
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
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

                        // Email (không thể chỉnh sửa)
                        TextFormField(
                          initialValue: _currentUserData['email'],
                          enabled: false,
                          decoration: _inputDecoration(
                            context,
                            label: 'Email',
                            hint: 'Email không thể thay đổi',
                            icon: Icons.email_outlined,
                            isDisabled: true,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Số điện thoại
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
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
                              r'^[+]?[0-9\s-()]{10,15}$',
                            ).hasMatch(value.trim())) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Ngành học
                        TextFormField(
                          controller: _majorController,
                          decoration: _inputDecoration(
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

                        // Nút lưu thay đổi
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.hintColor.withOpacity(isDisabled ? 0.5 : 0.7),
        fontSize: 16,
      ),
      labelStyle: TextStyle(
        color: isDisabled ? theme.hintColor.withOpacity(0.5) : theme.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color:
            isDisabled
                ? theme.hintColor.withOpacity(0.5)
                : theme.colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          icon,
          color:
              isDisabled ? theme.hintColor.withOpacity(0.5) : theme.hintColor,
          size: 22,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      suffixIcon:
          suffix != null
              ? Padding(padding: const EdgeInsets.only(left: 12), child: suffix)
              : (isDisabled ? const Icon(Icons.lock_outline, size: 20) : null),
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
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.3),
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
