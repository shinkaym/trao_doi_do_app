import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class CustomImageField extends StatelessWidget {
  final String label;
  final List<File> imageFiles;
  final void Function(List<File>) onImagesSelected;

  const CustomImageField({
    super.key,
    required this.label,
    required this.imageFiles,
    required this.onImagesSelected,
  });

  Future<void> _pickImages(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage(imageQuality: 75);
      if (pickedFiles.isNotEmpty) {
        onImagesSelected(pickedFiles.map((x) => File(x.path)).toList());
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        onImagesSelected([...imageFiles, File(pickedFile.path)]);
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn ảnh từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImageSourceActionSheet(context),
            child: Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: ext.primaryTextColor),
                borderRadius: BorderRadius.circular(8),
                color: ext.card,
              ),
              child:
                  imageFiles.isNotEmpty
                      ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            imageFiles
                                .map(
                                  (file) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                                .toList(),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate_outlined, size: 32),
                          SizedBox(height: 8),
                          Text('Tải ảnh lên hoặc chụp ảnh'),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
