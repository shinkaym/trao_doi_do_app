import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/edit_profile/avatar_section.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_select.dart';
import 'package:trao_doi_do_app/presentation/widgets/image_picker_bottom_sheet.dart';
import 'dart:io';
import 'package:trao_doi_do_app/presentation/widgets/custom_input_decoration.dart';
import 'package:trao_doi_do_app/presentation/widgets/smart_scaffold.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  static const List<String> majorOptions = [
    'Công nghệ Kỹ thuật Điện',
    'Công nghệ Kỹ thuật Điện tử - Viễn thông',
    'Công nghệ Kỹ thuật Cơ khí',
    'Công nghệ Kỹ thuật Ô tô',
    'Công nghệ Thông tin',
    'Công nghệ Kỹ thuật Nhiệt',
    'Công nghệ Kỹ thuật Điều khiển và Tự động hóa',
    'Công nghệ Kỹ thuật Cơ điện tử',
    'Kế toán tin học',
    'Cơ khí chế tạo',
    'Sửa chữa cơ khí',
    'Hàn',
    'Kỹ thuật máy lạnh và điều hòa không khí',
    'Bảo trì, sửa chữa Ô tô',
    'Điện công nghiệp',
    'Điện tử công nghiệp',
    'Quản trị mạng máy tính',
    'Kỹ thuật sửa chữa, lắp ráp máy tính',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks for form controllers
    final fullNameController = useTextEditingController();
    final addressController = useTextEditingController();

    // Hooks for state management
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final selectedImage = useState<File?>(null);
    final picker = useMemoized(() => ImagePicker());
    final autovalidateMode = useState(AutovalidateMode.disabled);
    final selectedMajor = useState<String?>(null);

    final debouncer = useMemoized(() => Debouncer());

    // Watch auth state to get user data
    final authState = ref.watch(authProvider);

    useEffect(() {
      return () {
        debouncer.cancel();
      };
    }, []);

    // Initialize controllers with user data
    useEffect(() {
      if (authState.user != null) {
        fullNameController.text = authState.user!.fullName;
        addressController.text = authState.user!.address;

        // Kiểm tra xem major của user có trong danh sách không
        final userMajor = authState.user!.major;
        if (userMajor.isNotEmpty && majorOptions.contains(userMajor)) {
          selectedMajor.value = userMajor;
        } else {
          // Nếu major không có trong danh sách, set về null
          selectedMajor.value = null;
        }
      }
      return null;
    }, [authState.user]);

    // Listen for auth state changes
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
          // Reset autovalidate mode sau khi lưu thành công
          autovalidateMode.value = AutovalidateMode.disabled;
        });
      }
      return null;
    }, [authState.failure, authState.successMessage]);

    // Tính toán xem có thay đổi gì không
    bool hasChanges() {
      if (authState.user == null) return false;

      final hasNameChanged =
          fullNameController.text != authState.user!.fullName;
      final hasAddressChanged =
          addressController.text != authState.user!.address;
      final hasMajorChanged =
          selectedMajor.value != null &&
          selectedMajor.value != authState.user!.major;
      final hasAvatarChanged = selectedImage.value != null;

      return hasNameChanged ||
          hasAddressChanged ||
          hasMajorChanged ||
          hasAvatarChanged;
    }

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
        context.showErrorSnackBar('Lỗi khi chọn ảnh');
      }
    }

    Future<void> handleSave() async {
      // Kiểm tra xem có thay đổi gì không, nếu không có thì return
      if (!hasChanges()) {
        return;
      }

      // Kiểm tra các trường nào đã thay đổi để áp dụng validate tương ứng
      final hasNameChanged =
          fullNameController.text != authState.user?.fullName;
      final hasAddressChanged =
          addressController.text != authState.user?.address;
      final hasMajorChanged =
          selectedMajor.value != null &&
          selectedMajor.value != authState.user?.major;
      final hasAvatarChanged = selectedImage.value != null;

      // Bật autovalidate cho các trường đã thay đổi
      if (hasNameChanged || hasAddressChanged || hasMajorChanged) {
        autovalidateMode.value = AutovalidateMode.onUserInteraction;
      }

      // Validate form trước khi tiếp tục
      if (!formKey.currentState!.validate()) {
        // context.showErrorSnackBar(
        //   'Vui lòng điền đầy đủ thông tin cho các mục bạn muốn thay đổi',
        // );
        return;
      }

      // Nếu chỉ thay đổi avatar mà không thay đổi gì khác
      if (hasAvatarChanged &&
          !hasNameChanged &&
          !hasAddressChanged &&
          !hasMajorChanged) {
        isLoading.value = true;
        final bytes = await selectedImage.value!.readAsBytes();
        final updatedAvatar = Base64Utils.encodeImageToDataUri(bytes);

        await ref
            .read(authProvider.notifier)
            .updateProfile(userId: authState.user!.id, avatar: updatedAvatar);

        // Reset selectedImage sau khi lưu thành công
        selectedImage.value = null;
        isLoading.value = false;
        return;
      }

      isLoading.value = true;

      // Track which fields have actually changed
      String? updatedFullName;
      String? updatedAddress;
      String? updatedMajor;
      String? updatedAvatar;

      final currentUser = authState.user;
      if (currentUser == null) {
        context.showErrorSnackBar('Không tìm thấy thông tin người dùng');
        isLoading.value = false;
        return;
      }

      // Check each field for changes
      if (hasNameChanged) {
        updatedFullName = fullNameController.text.trim();
      }

      if (hasAddressChanged) {
        updatedAddress = addressController.text.trim();
      }

      if (hasMajorChanged) {
        updatedMajor = selectedMajor.value ?? '';
      }

      // Handle avatar update
      if (hasAvatarChanged) {
        final bytes = await selectedImage.value!.readAsBytes();
        updatedAvatar = Base64Utils.encodeImageToDataUri(bytes);
      }

      // Build change summary for user feedback
      final List<String> changedFields = [];
      if (updatedFullName != null) changedFields.add('Họ tên');
      if (updatedAddress != null) changedFields.add('Địa chỉ');
      if (updatedMajor != null) changedFields.add('Ngành học');
      if (updatedAvatar != null) changedFields.add('Ảnh đại diện');

      // Call update with only changed fields
      await ref
          .read(authProvider.notifier)
          .updateProfile(
            userId: currentUser.id,
            fullName: updatedFullName,
            address: updatedAddress,
            major: updatedMajor,
            avatar: updatedAvatar,
          );

      // Reset selectedImage sau khi lưu thành công
      if (hasAvatarChanged) {
        selectedImage.value = null;
      }

      isLoading.value = false;
    }

    Future<void> handleSaveDebounced() async {
      const duration = Duration(milliseconds: 800);

      debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          await handleSave();
        },
      );
    }

    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    return SmartScaffold(
      appBarType: AppBarType.standard,
      title: 'Chỉnh sửa thông tin',
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
                    autovalidateMode: autovalidateMode.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Display-only fields
                        _buildInfoSection(context, 'Thông tin cơ bản', [
                          _buildDisplayField(
                            context,
                            'Email',
                            authState.user?.email ?? '',
                            Icons.email_outlined,
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          _buildDisplayField(
                            context,
                            'Số điện thoại',
                            authState.user?.phoneNumber ?? '',
                            Icons.phone_outlined,
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          _buildDisplayField(
                            context,
                            'Điểm tốt',
                            '${authState.user?.goodPoint ?? 0} điểm',
                            Icons.star_outline,
                          ),
                        ]),

                        SizedBox(height: isTablet ? 32 : 24),

                        // Editable fields
                        _buildInfoSection(
                          context,
                          'Thông tin có thể chỉnh sửa',
                          [
                            TextFormField(
                              controller: fullNameController,
                              enabled: !isLoading.value,
                              decoration: CustomInputDecoration.build(
                                context,
                                label: 'Họ và tên',
                                hint: 'Nhập họ và tên của bạn',
                                icon: Icons.person_outline,
                              ),
                              validator: (value) {
                                // Chỉ validate nếu trường này đã thay đổi
                                final hasChanged =
                                    fullNameController.text !=
                                    authState.user?.fullName;
                                if (hasChanged) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập họ và tên';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Họ và tên phải có ít nhất 2 ký tự';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isTablet ? 20 : 16),

                            TextFormField(
                              controller: addressController,
                              enabled: !isLoading.value,
                              maxLines: 2,
                              decoration: CustomInputDecoration.build(
                                context,
                                label: 'Địa chỉ',
                                hint: 'Nhập địa chỉ của bạn',
                                icon: Icons.location_on_outlined,
                              ),
                              validator: (value) {
                                // Chỉ validate nếu trường này đã thay đổi
                                final hasChanged =
                                    addressController.text !=
                                    authState.user?.address;
                                if (hasChanged) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập địa chỉ';
                                  }
                                  if (value.trim().length < 5) {
                                    return 'Địa chỉ phải có ít nhất 5 ký tự';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isTablet ? 20 : 16),

                            CustomSelect(
                              label: 'Ngành học',
                              hint: 'Chọn ngành học của bạn',
                              icon: Icons.school_outlined,
                              value: selectedMajor.value,
                              items: majorOptions,
                              enabled: !isLoading.value,
                              onChanged: (String? value) {
                                selectedMajor.value = value;
                              },
                              validator: (value) {
                                // Chỉ validate nếu trường này đã thay đổi
                                final hasChanged =
                                    selectedMajor.value != null &&
                                    selectedMajor.value !=
                                        authState.user?.major;
                                if (hasChanged) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng chọn ngành học';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 40 : 32),

                        // Save button
                        SizedBox(
                          height: isTablet ? 56 : 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                !isLoading.value ? handleSaveDebounced : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon:
                                isLoading.value
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
                              isLoading.value ? 'Đang lưu...' : 'Lưu thay đổi',
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

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        ...children,
      ],
    );
  }

  Widget _buildDisplayField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: isTablet ? 24 : 20,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Chưa có thông tin' : value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w400,
                    color:
                        value.isEmpty
                            ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
