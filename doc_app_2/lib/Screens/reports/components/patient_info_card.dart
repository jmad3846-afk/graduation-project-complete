import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class PatientInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const PatientInfoCard(this.primary, this.secondary, {super.key});

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Patient Information",
      [
        reportTextField("Patient Name", primary, secondary),
        reportRadioRow(
          "Emergency Code",
          ["Red", "Yellow", "Green"],
          primary,
          secondary,
        ),
        Row(
          children: [
            Expanded(
              child: reportTextField("Age", primary, secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reportTextField("Weight (kg)", primary, secondary),
            ),
          ],
        ),
        reportTextField(
          "Medical History",
          primary,
          secondary,
          maxLines: 3,
        ),
      ],
      primary,
    );
  }
}
