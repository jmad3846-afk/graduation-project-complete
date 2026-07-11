import 'package:flutter/material.dart';

import '_base_info_card.dart';

class MedicalInfoCard extends StatelessWidget {
  const MedicalInfoCard({super.key, required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return BaseInfoCard(
      primary: primary,
      secondary: secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medical Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primary)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Symptoms',
              labelStyle: TextStyle(color: secondary),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Diagnosis (optional)',
              labelStyle: TextStyle(color: secondary),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

