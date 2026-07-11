import 'package:flutter/material.dart';

import '../shared/custom_radio_row.dart';
import '_base_info_card.dart';

class CallerInfoCard extends StatefulWidget {
  const CallerInfoCard({super.key, required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  State<CallerInfoCard> createState() => _CallerInfoCardState();
}

class _CallerInfoCardState extends State<CallerInfoCard> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _emergencyCode;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseInfoCard(
      primary: widget.primary,
      secondary: widget.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Caller Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: widget.primary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Caller Name',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomRadioRow<String>(
            title: 'Emergency Code',
            value: _emergencyCode ?? 'Red',
            options: const {
              'Red': 'Red',
              'Yellow': 'Yellow',
              'Green': 'Green',
            },
            onChanged: (v) => setState(() => _emergencyCode = v),
          ),
        ],
      ),
    );
  }
}

