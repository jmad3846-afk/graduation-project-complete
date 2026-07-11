// lib/presentation/reports/components/medical_info_card.dart
import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class MedicalInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  // Controllers for editable fields
  final TextEditingController oxygenLevelController;
  final TextEditingController bloodPressureController;
  final TextEditingController bloodSugarController;
  final TextEditingController oxygenSupportLevelController;
  final TextEditingController oxygenAfterSupportController;
  // Boolean notifiers
  final ValueNotifier<bool> intubatedNotifier;
  final ValueNotifier<bool> consciousNotifier;

  const MedicalInfoCard({
    required this.primary,
    required this.secondary,
    required this.oxygenLevelController,
    required this.bloodPressureController,
    required this.bloodSugarController,
    required this.oxygenSupportLevelController,
    required this.oxygenAfterSupportController,
    required this.intubatedNotifier,
    required this.consciousNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Medical Information",
      [
        Row(
          children: [
            Expanded(
              child: reportTextField("Oxygen Level", primary, secondary, controller: oxygenLevelController),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reportTextField("Blood Pressure", primary, secondary, controller: bloodPressureController),
            ),
          ],
        ),
        reportTextField("Blood Sugar", primary, secondary, controller: bloodSugarController),
        reportTextField("Oxygen Support Level", primary, secondary, controller: oxygenSupportLevelController),
        reportTextField("Oxygen Level After Support", primary, secondary, controller: oxygenAfterSupportController),
        ValueListenableBuilder<bool>(
          valueListenable: intubatedNotifier,
          builder: (context, value, _) => SwitchListTile(
            title: const Text("Is Patient Intubated?"),
            value: value,
            activeThumbColor: primary,
            onChanged: (v) => intubatedNotifier.value = v,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: consciousNotifier,
          builder: (context, value, _) => SwitchListTile(
            title: const Text("Is Patient Conscious?"),
            value: value,
            activeThumbColor: primary,
            onChanged: (v) => consciousNotifier.value = v,
          ),
        ),
      ],
      primary,
    );
  }
}
