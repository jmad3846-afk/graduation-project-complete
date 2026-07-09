import 'package:flutter/material.dart';

class SelectableDetailColumn extends StatelessWidget {
  final String label;
  final String keyName;
  final String initialValue;
  final String missionId;
  final Function(String missionId, String key, String value) onUpdate;
  final List<String> options;
  final double width;

  const SelectableDetailColumn({
    super.key,
    required this.label,
    required this.keyName,
    required this.initialValue,
    required this.missionId,
    required this.onUpdate,
    required this.options,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get colors based on current theme (same as EditableDetailColumn)
    final secondaryColor = theme.colorScheme.secondary;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.grey[800] : Colors.grey[100]);

    String? currentValue =
    options.contains(initialValue) ? initialValue : options.first;

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
          SizedBox(
            height: 40,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonFormField<String>(
                initialValue: currentValue,
                isExpanded: true,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: fillColor ?? Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1,
                    ),
                  ),
                ),
                dropdownColor: fillColor,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: textColor,
                ),
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onUpdate(missionId, keyName, newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}