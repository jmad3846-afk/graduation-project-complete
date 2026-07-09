// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TimeInputColumn extends StatelessWidget {
  final String label;
  final String timeKey;
  final String initialValue;
  final String missionId;
  final Function(String missionId, String key, String value) onTimeUpdate;
  final double width;

  const TimeInputColumn({
    super.key,
    required this.label,
    required this.timeKey,
    required this.initialValue,
    required this.missionId,
    required this.onTimeUpdate,
    this.width = 150,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialValue.isNotEmpty
          ? TimeOfDay(
        hour: int.parse(initialValue.split(':')[0]),
        minute: int.parse(initialValue.split(':')[1]),
      )
          : TimeOfDay.now(),
    );

    if (picked != null) {
      final String formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeUpdate(missionId, timeKey, formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get colors based on current theme (same as EditableDetailColumn)
    final secondaryColor = theme.colorScheme.secondary;
    final textColor = theme.colorScheme.onSurface;
    final fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.grey[800] : Colors.grey[100]);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () => _selectTime(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 40,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (initialValue.isEmpty)
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: secondaryColor.withOpacity(0.7),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      initialValue.isEmpty ? 'تحديد الوقت' : initialValue,
                      style: TextStyle(
                        color: initialValue.isEmpty
                            ? secondaryColor.withOpacity(0.7)
                            : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
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