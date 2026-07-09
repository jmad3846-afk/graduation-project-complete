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
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Report Time',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reportDateController,
          style: TextStyle(color: primary),
          decoration: InputDecoration(
            labelText: 'Report Date',
            labelStyle: TextStyle(color: secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}
