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
  final TextEditingController oxygenBeforeController;
  final TextEditingController oxygenAfterController;
  final ValueNotifier<String> emergencyCodeNotifier;

  const PatientInfoCard({
    required this.primary,
    required this.secondary,
    required this.patientNameController,
    required this.ageController,
    required this.weightController,
    required this.medicalHistoryController,
    required this.oxygenBeforeController,
    required this.oxygenAfterController,
    required this.emergencyCodeNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Patient Information",
      [
        reportTextField("Patient Name", primary, secondary, controller: patientNameController),
        ValueListenableBuilder<String>(
          valueListenable: emergencyCodeNotifier,
          builder: (context, value, _) => reportRadioRow(
            "Emergency Code",
            ["Red", "Yellow", "Green"],
            primary,
            secondary,
            groupValue: value,
            onChanged: (v) {
              if (v != null) emergencyCodeNotifier.value = v;
            },
          ),
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
        Row(
          children: [
            Expanded(
              child: reportTextField("Oxygen Before", primary, secondary, controller: oxygenBeforeController),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reportTextField("Oxygen After", primary, secondary, controller: oxygenAfterController),
            ),
          ],
        ),
      ],
      primary,
    );
  }
}
