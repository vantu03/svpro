import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final TextInputType keyboardType;
  final bool isPassword;
  final int? minLength;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? Function(String?)? customValidator;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = true,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.minLength,
    this.maxLength,
    this.inputFormatters,
    this.hintText,
    this.customValidator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          counterText: "",
        ),
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Không được để trống';
          }
          if (minLength != null && value!.length < minLength!) {
            return 'Tối thiểu $minLength ký tự';
          }
          if (maxLength != null && value!.length > maxLength!) {
            return 'Tối đa $minLength ký tự';
          }
          if (customValidator != null) {
            return customValidator!(value);
          }
          return null;
        },
      ),
    );
  }
}
