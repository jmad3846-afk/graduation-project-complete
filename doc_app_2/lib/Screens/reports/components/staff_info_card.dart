import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class StaffInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const StaffInfoCard(this.primary, this.secondary, {super.key});

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Staff Information",
      [
        reportTextField("Operations Officer", primary, secondary),
        reportTextField("Sector Commander", primary, secondary),
      ],
      primary,
    );
  }
}
