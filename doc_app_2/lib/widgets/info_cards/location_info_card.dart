import 'package:flutter/material.dart';

import '_base_info_card.dart';

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard({super.key, required this.primary, required this.secondary});

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
          Text('Location Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primary)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Address',
              labelStyle: TextStyle(color: secondary),
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'City / Area',
              labelStyle: TextStyle(color: secondary),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

