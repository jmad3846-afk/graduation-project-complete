// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget infoCard(
    String title,
    List<Widget> children,
    Color primary,
    ) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: e,
          ),
        ),
      ],
    ),
  );
}

Widget reportTextField(
    String label,
    Color primary,
    Color secondary, {
      int maxLines = 1,
      TextEditingController? controller,
    }) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(color: primary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

Widget reportRadioRow(
    String label,
    List<String> options,
    Color primary,
    Color secondary, {
      required String? groupValue,
      required ValueChanged<String?> onChanged,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: primary)),
      Row(
        children: options
            .map(
              (o) => Row(
            children: [
              Radio<String>(
                value: o,
                groupValue: groupValue,
                onChanged: onChanged,
                fillColor: WidgetStateProperty.all(primary),
              ),
              Text(o, style: TextStyle(color: secondary)),
            ],
          ),
        )
            .toList(),
      ),
    ],
  );
}
