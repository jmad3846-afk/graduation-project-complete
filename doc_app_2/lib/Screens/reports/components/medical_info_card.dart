import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class MedicalInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const MedicalInfoCard(this.primary, this.secondary, {super.key});

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Medical Information",
      [
        Row(
          children: [
            Expanded(
              child: reportTextField("Oxygen Level", primary, secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reportTextField("Blood Pressure", primary, secondary),
            ),
          ],
        ),
        reportTextField("Blood Sugar", primary, secondary),
        reportTextField("Oxygen Support Level", primary, secondary),
        reportTextField(
            "Oxygen Level After Support", primary, secondary),
        reportRadioRow(
          "Is Patient Intubated?",
          ["Yes", "No"],
          primary,
          secondary,
        ),
        reportRadioRow(
          "Is Patient Conscious?",
          ["Yes", "No"],
          primary,
          secondary,
        ),
      ],
      primary,
    );
  }
}
