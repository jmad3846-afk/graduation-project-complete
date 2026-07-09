import 'package:flutter/material.dart';
import '../../../core/app_themes.dart';

class EditableDetailColumn extends StatefulWidget {
  final String label;
  final String keyName;
  final String initialValue;
  final String missionId;
  final Function(String missionId, String key, String value) onUpdate;
  final double width;

  const EditableDetailColumn({
    super.key,
    required this.label,
    required this.keyName,
    required this.initialValue,
    required this.missionId,
    required this.onUpdate,
    this.width = 150,
  });

  @override
  State<EditableDetailColumn> createState() => _EditableDetailColumnState();
}

class _EditableDetailColumnState extends State<EditableDetailColumn> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant EditableDetailColumn oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller only if the value changed externally
    if (oldWidget.initialValue != widget.initialValue) {
      if (_controller.text != widget.initialValue &&
          !FocusScope.of(context).hasFocus) {
        _controller.text = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get colors based on current theme
    final secondaryColor = isDark
        ? AppThemes.darkTheme.colorScheme.secondary
        : AppThemes.lightTheme.colorScheme.secondary;

    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final hintColor = theme.hintColor;
    final fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.grey[800] : Colors.grey[100]);

    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            widget.label,
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
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'أدخل القيمة',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
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
                  isDense: true,
                ),
                onSubmitted: (value) {
                  widget.onUpdate(
                    widget.missionId,
                    widget.keyName,
                    value.trim(),
                  );
                },
                onEditingComplete: () {
                  widget.onUpdate(
                    widget.missionId,
                    widget.keyName,
                    _controller.text.trim(),
                  );
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}