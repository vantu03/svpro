import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? customValidator;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = true,
    this.hintText,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        items: items.entries
            .map((e) =>
            DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
        validator: (v) {
          if (isRequired && v == null) return 'Vui lòng chọn $label';
          if (customValidator != null) return customValidator!(v);
          return null;
        },
      ),
    );
  }
}
