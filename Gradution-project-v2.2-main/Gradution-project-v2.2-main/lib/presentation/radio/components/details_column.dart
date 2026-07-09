import 'package:flutter/material.dart';

class DetailsColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color? valueColor;
  final double width;

  const DetailsColumn({
    super.key,
    required this.label,
    required this.value,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.valueColor,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: valueColor ?? primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}