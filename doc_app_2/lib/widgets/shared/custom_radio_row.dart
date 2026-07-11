// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomRadioRow<T> extends StatelessWidget {
  const CustomRadioRow({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: options.entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<T>(
                  value: e.key,
                  groupValue: value,
                  onChanged: onChanged,
                ),
                Text(e.value),
              ],
            );
          }).toList(),
        ),

      ],
    );
  }
}


