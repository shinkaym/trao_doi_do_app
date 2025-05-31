import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:trao_doi_do_app/presentation/widgets/custom_appbar.dart';

enum PostType { lostItem, foundItem, giveAway, freePost }

class CreatePostScreen extends StatefulWidget {
  final bool isLoggedIn;

  const CreatePostScreen({Key? key, this.isLoggedIn = false}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Common fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Lost item fields
  final _rewardController = TextEditingController();
  DateTime? _lostDate;
  final _lostLocationController = TextEditingController();
  String? _lostCategory;

  // Found item fields
  DateTime? _foundDate;
  final _foundLocationController = TextEditingController();
  String? _foundCategory;

  // Give away fields
  final _conditionController = TextEditingController();
  String? _giveAwayCategory;

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _categories = [
    'Điện tử',
    'Quần áo',
    'Phụ kiện',
    'Tài liệu',
    'Chìa khóa',
    'Ví/Túi',
    'Đồ trang sức',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _lostLocationController.dispose();
    _foundLocationController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  PostType get _currentPostType {
    switch (_tabController.index) {
      case 0:
        return PostType.lostItem;
      case 1:
        return PostType.foundItem;
      case 2:
        return PostType.giveAway;
      case 3:
        return PostType.freePost;
      default:
        return PostType.lostItem;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 4) {
      _showSnackBar('Chỉ được chọn tối đa 4 ảnh', Colors.orange);
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final int fileSize = await imageFile.length();

        if (fileSize > 5 * 1024 * 1024) {
          _showSnackBar('Ảnh không được vượt quá 5MB', Colors.red);
          return;
        }

        setState(() {
          _selectedImages.add(imageFile);
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh', Colors.red);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),
                  Text(
                    'Chọn ảnh',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.camera_alt,
                          label: 'Chụp ảnh',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_library,
                          label: 'Thư viện',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isLostDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isLostDate) {
          _lostDate = picked;
        } else {
          _foundDate = picked;
        }
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnackBar('Vui lòng chọn ít nhất một ảnh', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    _showSnackBar('Đăng bài thành công!', Colors.green);

    // Reset form or navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Tạo bài đăng',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        notificationCount: 3,
        onNotificationTap: () {
          context.pushNamed('notifications');
        },
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Tìm đồ thất lạc'),
            Tab(text: 'Nhặt được đồ'),
            Tab(text: 'Gửi đồ cũ'),
            Tab(text: 'Bài đăng tự do'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLostItemForm(),
            _buildFoundItemForm(),
            _buildGiveAwayForm(),
            _buildFreePostForm(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
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
                        'Đăng bài',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLostItemForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isLoggedIn) ...[
            _buildUserInfoSection(),
            const SizedBox(height: 24),
          ],
          _buildCommonFields(),
          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin đồ thất lạc'),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Ngày bị mất',
            date: _lostDate,
            onTap: () => _selectDate(context, isLostDate: true),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lostLocationController,
            label: 'Nơi bị mất',
            hint: 'Nhập địa điểm bị mất đồ',
            icon: Icons.location_on_outlined,
            validator:
                (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập nơi bị mất' : null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Loại đồ vật',
            value: _lostCategory,
            items: _categories,
            onChanged: (value) => setState(() => _lostCategory = value),
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _rewardController,
            label: 'Mô tả thưởng/cảm ơn',
            hint: 'Mô tả cách bạn muốn cảm ơn người tìm thấy (tiền thưởng, quà, hoặc lời cảm ơn...)',
            icon: Icons.card_giftcard_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFoundItemForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isLoggedIn) ...[
            _buildUserInfoSection(),
            const SizedBox(height: 24),
          ],
          _buildCommonFields(),
          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin đồ nhặt được'),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Ngày nhặt được',
            date: _foundDate,
            onTap: () => _selectDate(context, isLostDate: false),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _foundLocationController,
            label: 'Nơi nhặt được',
            hint: 'Nhập địa điểm nhặt được đồ',
            icon: Icons.location_on_outlined,
            validator:
                (value) =>
                    value?.isEmpty == true
                        ? 'Vui lòng nhập nơi nhặt được'
                        : null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Loại đồ vật',
            value: _foundCategory,
            items: _categories,
            onChanged: (value) => setState(() => _foundCategory = value),
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGiveAwayForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isLoggedIn) ...[
            _buildUserInfoSection(),
            const SizedBox(height: 24),
          ],
          _buildCommonFields(),
          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin đồ cũ'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _conditionController,
            label: 'Tình trạng đồ',
            hint: 'Mô tả tình trạng hiện tại của đồ vật (mới, cũ, hỏng,...)',
            icon: Icons.info_outline,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Danh mục đồ',
            value: _giveAwayCategory,
            items: _categories,
            onChanged: (value) => setState(() => _giveAwayCategory = value),
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFreePostForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isLoggedIn) ...[
            _buildUserInfoSection(),
            const SizedBox(height: 24),
          ],
          _buildCommonFields(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserGuideCard(),
        _buildSectionTitle('Thông tin liên hệ'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Họ và tên',
          hint: 'Nhập họ và tên của bạn',
          icon: Icons.person_outline,
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Vui lòng nhập họ và tên' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Nhập email của bạn',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) return 'Vui lòng nhập email';
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại của bạn',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty == true) return 'Vui lòng nhập số điện thoại';
            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value!)) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin bài đăng'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'Tiêu đề bài đăng',
          hint: 'Nhập tiêu đề cho bài đăng',
          icon: Icons.title_outlined,
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Mô tả chi tiết',
          hint: 'Mô tả chi tiết về đồ vật...',
          icon: Icons.description_outlined,
          maxLines: 4,
          validator:
              (value) => value?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
        ),
        const SizedBox(height: 16),
        _buildImageSection(),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Hình ảnh (${_selectedImages.length}/4)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tối đa 4 ảnh, mỗi ảnh không quá 5MB',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._selectedImages.asMap().entries.map((entry) {
              return _buildImageItem(entry.value, entry.key);
            }),
            if (_selectedImages.length < 4) _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.add_a_photo,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Vui lòng chọn $label' : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Chọn ngày',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          controller: TextEditingController(
            text:
                date != null
                    ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                    : '',
          ),
          validator:
              (value) => value?.isEmpty == true ? 'Vui lòng chọn ngày' : null,
        ),
      ),
    );
  }

  Widget _buildUserGuideCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin quan trọng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nếu chưa đăng nhập, thông tin liên hệ sẽ được tạo thành tài khoản. Lần sau đăng nhập, bạn nhớ xác thực email để kích hoạt tài khoản.',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 13,
                    height: 1.3,
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