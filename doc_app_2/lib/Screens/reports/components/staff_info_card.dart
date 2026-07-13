import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class StaffInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final TextEditingController operationsOfficerController;
  final TextEditingController sectorCommanderController;
  final TextEditingController medicalAidGivenController;

  const StaffInfoCard(
    this.primary,
    this.secondary, {
    required this.operationsOfficerController,
    required this.sectorCommanderController,
    required this.medicalAidGivenController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Staff Information",
      [
        reportTextField("Operations Officer", primary, secondary, controller: operationsOfficerController),
        reportTextField("Sector Commander", primary, secondary, controller: sectorCommanderController),
        reportTextField(
          "Medical Aid Given",
          primary,
          secondary,
          controller: medicalAidGivenController,
          maxLines: 3,
        ),
      ],
      primary,
    );
  }
}
