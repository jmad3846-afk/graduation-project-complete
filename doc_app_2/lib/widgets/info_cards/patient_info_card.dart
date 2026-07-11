import 'package:flutter/material.dart';

import '../shared/custom_radio_row.dart';
import '_base_info_card.dart';

class PatientInfoCard extends StatefulWidget {
  const PatientInfoCard({super.key, required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  State<PatientInfoCard> createState() => _PatientInfoCardState();
}

class _PatientInfoCardState extends State<PatientInfoCard> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _intubated = false;
  bool _conscious = true;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
          Text('Patient Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: widget.primary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Patient Name',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Age',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomRadioRow<bool>(
            title: 'Is Patient Intubated?',
            value: _intubated,
            options: const {
              false: 'No',
              true: 'Yes',
            },
            onChanged: (v) => setState(() => _intubated = v ?? false),
          ),
          const SizedBox(height: 12),
          CustomRadioRow<bool>(
            title: 'Is Patient Conscious?',
            value: _conscious,
            options: const {
              false: 'No',
              true: 'Yes',
            },
            onChanged: (v) => setState(() => _conscious = v ?? true),
          ),
        ],
      ),
    );
  }
}

