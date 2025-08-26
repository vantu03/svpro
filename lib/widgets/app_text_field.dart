import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final bool showRequiredAsterisk;
  final TextInputType keyboardType;
  final bool isPassword;
  final int? minLength;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? Function(String?)? customValidator;
  final int? maxLines;
  final String counterText;
  final String? defaultText;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final num? minValue;
  final num? maxValue;


  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = true,
    this.showRequiredAsterisk = true,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.minLength,
    this.maxLength,
    this.inputFormatters,
    this.hintText,
    this.customValidator,
    this.maxLines,
    this.counterText = "",
    this.defaultText,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.minValue,
    this.maxValue,
  });

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  @override
  void initState() {
    super.initState();
    if (widget.defaultText != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.defaultText!;
    }
  }

  Widget buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.inputDecorationTheme.labelStyle ?? theme.textTheme.bodyMedium;

    return RichText(
      text: TextSpan(
        style: baseStyle?.copyWith(
          color: widget.enabled ? baseStyle.color : theme.disabledColor,
        ),
        children: [
          TextSpan(text: widget.label),
          if (widget.isRequired && widget.showRequiredAsterisk)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        obscureText: widget.isPassword,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines ?? 1,
        decoration: InputDecoration(
          label: buildLabel(context),
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          counterText: widget.counterText,
          suffixIcon: widget.suffixIcon,
        ),
        validator: (value) {
          final v = value?.trim() ?? '';
          if (widget.isRequired && v.isEmpty) {
            return 'Không được để trống';
          }
          if (widget.minLength != null && v.length < widget.minLength!) {
            return 'Tối thiểu ${widget.minLength} ký tự';
          }
          if (widget.maxLength != null && v.length > widget.maxLength!) {
            return 'Tối đa ${widget.maxLength} ký tự';
          }
          if (widget.minValue != null || widget.maxValue != null) {
            final num? number = num.tryParse(v.replaceAll(",", ""));
            if (number == null) {
              return 'Giá trị phải là số';
            }
            if (widget.minValue != null && number < widget.minValue!) {
              return 'Tối thiểu là ${widget.minValue}';
            }
            if (widget.maxValue != null && number > widget.maxValue!) {
              return 'Tối đa là ${widget.maxValue}';
            }
          }
          if (widget.customValidator != null) {
            return widget.customValidator!(v);
          }
          return null;
        },
      ),
    );
  }
}
