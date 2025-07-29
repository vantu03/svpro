import 'package:flutter/material.dart';

class DatePickerTile extends StatelessWidget {
  final String? label;
  final DateTime? date;
  final void Function(DateTime?) onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  const DatePickerTile({
    super.key,
    this.label,
    required this.date,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
  });


  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime(2000),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = date != null
        ? "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}"
        : "--/--/----";

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          GestureDetector(
            onTap: () => pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
