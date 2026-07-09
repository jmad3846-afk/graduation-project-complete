// lib/presentation/reports/components/patient_info_card.dart
import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class PatientInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final TextEditingController patientNameController;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final TextEditingController medicalHistoryController;

  const PatientInfoCard({
    required this.primary,
    required this.secondary,
    required this.patientNameController,
    required this.ageController,
    required this.weightController,
    required this.medicalHistoryController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Patient Information",
      [
        reportTextField("Patient Name", primary, secondary, controller: patientNameController),
        reportRadioRow(
          "Emergency Code",
          ["Red", "Yellow", "Green"],
          primary,
          secondary,
        ),
        Row(
          children: [
            Expanded(
              child: reportTextField("Age", primary, secondary, controller: ageController),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reportTextField("Weight (kg)", primary, secondary, controller: weightController),
            ),
          ],
        ),
        reportTextField(
          "Medical History",
          primary,
          secondary,
          controller: medicalHistoryController,
          maxLines: 3,
        ),
      ],
      primary,
    );
  }
}
