import 'package:flutter/material.dart';

import 'caller_info_card.dart';
import 'location_info_card.dart';
import 'medical_info_card.dart';
import 'patient_info_card.dart';
import 'report_header.dart';
import 'staff_info_card.dart';

class ReportsBody extends StatelessWidget {
  const ReportsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = isDark ? Colors.white : Colors.black87;
    final secondary = isDark ? Colors.white70 : Colors.grey[600]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const ReportHeader(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CallerInfoCard(primary, secondary)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: PatientInfoCard(primary, secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: MedicalInfoCard(primary, secondary)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: LocationInfoCard(primary, secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StaffInfoCard(primary, secondary),
                const SizedBox(height: 20),
                _actionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _actionButton('Waiting'),
        const SizedBox(width: 12),
        _actionButton('Move'),
      ],
    );
  }

  Widget _actionButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }
}

