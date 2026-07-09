// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final Map<String, int> missionCounts;
  final bool isLargeScreen;

  const HeaderBar({
    super.key,
    required this.missionCounts,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerColor = isDark
        ? Colors.grey[900]
        : theme.primaryColor;

    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // left section
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  'Car traffic',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // mission counter chips (large screens only)
            if (isLargeScreen)
              Row(
                children: [
                  _buildMissionChip('Red', missionCounts['Red']!, Colors.red),
                  const SizedBox(width: 15),
                  _buildMissionChip('Yellow', missionCounts['Yellow']!, Colors.amber),
                  const SizedBox(width: 15),
                  _buildMissionChip('Green', missionCounts['Green']!, Colors.green),
                ],
              ),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'إضافة مهمة جديدة',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionChip(String status, int count, Color color) {
    return Row(
      children: [
        Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
