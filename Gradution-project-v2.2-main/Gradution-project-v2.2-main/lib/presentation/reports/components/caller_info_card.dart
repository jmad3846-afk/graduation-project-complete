import 'package:flutter/material.dart';

class CallerInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final TextEditingController callerNameController;
  final TextEditingController relationController;
  final TextEditingController relationNumberController;
  final TextEditingController reportTimeController;
  final TextEditingController reportDateController;

  const CallerInfoCard({
    required this.primary,
    required this.secondary,
    required this.callerNameController,
    required this.relationController,
    required this.relationNumberController,
    required this.reportTimeController,
    required this.reportDateController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Caller Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
        const SizedBox(height: 12),
        TextField(
          controller: callerNameController,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Caller Name',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: relationController,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Relation to Patient',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: relationNumberController,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Relation Number',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reportTimeController,
          readOnly: true,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Report Time',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            suffixIcon: Icon(Icons.access_time, color: secondary),
          ),
          onTap: () async {
            final now = TimeOfDay.now();
            final picked = await showTimePicker(
              context: context,
              initialTime: now,
            );
            if (picked != null) {
              final hour = picked.hour.toString().padLeft(2, '0');
              final minute = picked.minute.toString().padLeft(2, '0');
              reportTimeController.text = '$hour:$minute';
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reportDateController,
          readOnly: true,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Report Date',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            suffixIcon: Icon(Icons.calendar_today, color: secondary),
          ),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              final year = picked.year.toString().padLeft(4, '0');
              final month = picked.month.toString().padLeft(2, '0');
              final day = picked.day.toString().padLeft(2, '0');
              reportDateController.text = '$year-$month-$day';
            }
          },
        ),
      ],
    );
  }
}
