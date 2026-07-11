import 'package:flutter/material.dart';

import '_base_info_card.dart';

class StaffInfoCard extends StatefulWidget {
  const StaffInfoCard({super.key, required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  State<StaffInfoCard> createState() => _StaffInfoCardState();
}

class _StaffInfoCardState extends State<StaffInfoCard> {
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _doctorNameController.dispose();
    _notesController.dispose();
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
          Text('Staff Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: widget.primary)),
          const SizedBox(height: 12),
          TextField(
            controller: _doctorNameController,
            decoration: InputDecoration(
              labelText: 'Doctor Name',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes',
              labelStyle: TextStyle(color: widget.secondary),
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

