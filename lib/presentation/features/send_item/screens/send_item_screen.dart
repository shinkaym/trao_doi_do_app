import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_date_time_picker_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_image_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/custom_text_field.dart';
import 'package:trao_doi_do_app/presentation/widgets/label_switch.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';
import 'package:trao_doi_do_app/presentation/widgets/primary_button.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class SendItemScreen extends StatefulWidget {
  const SendItemScreen({super.key});

  @override
  State<SendItemScreen> createState() => _SendItemScreenState();
}

class _SendItemScreenState extends State<SendItemScreen> {
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<File> _images = [];
  DateTime? _selectedDate;
  bool _isAnonymous = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    // final

    return MainLayout(
      title: 'Gửi đồ cũ',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Họ tên',
              controller: _fullNameController,
              inputType: TextInputType.name,
            ),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              inputType: TextInputType.emailAddress,
            ),
            CustomTextField(
              label: 'Số điện thoại',
              controller: _phoneNumberController,
              inputType: TextInputType.phone,
            ),
            // Add your form fields and other widgets here
            CustomImageField(
              label: 'Hình ảnh',
              imageFiles: _images,
              onImagesSelected: (files) {
                setState(() {
                  _images = files;
                });
              },
            ),
            CustomDateTimePickerField(
              label: 'Ngày hẹn',
              selectedDateTime: _selectedDate,
              onDateTimeChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              withTime: true, // hoặc false nếu chỉ cần ngày
            ),
            CustomTextField(
              label: 'Địa điểm hẹn',
              controller: _addressController,
              inputType: TextInputType.streetAddress,
            ),
            CustomTextField(
              label: 'Mô tả',
              controller: _descriptionController,
              minLines: 4,
              maxLines: 8,
            ),
            LabeledSwitch(
              label: 'Ẩn danh',
              value: _isAnonymous,
              onChanged: (val) {
                setState(() {
                  _isAnonymous = val;
                });
              },
            ),
            PrimaryButton(
              text: 'Gửi đồ',
              onPressed: () {
                // Xử lý gửi thông tin
                // Bạn có thể thêm logic gửi dữ liệu ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thông tin đã được gửi thành công!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
