import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType inputType;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: inputType,
            obscureText: isPassword && !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: onToggleVisibility,
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
