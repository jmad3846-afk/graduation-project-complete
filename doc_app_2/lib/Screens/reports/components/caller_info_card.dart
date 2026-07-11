import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class CallerInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const CallerInfoCard(this.primary, this.secondary, {super.key});

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Caller Information",
      [
        reportTextField("Caller Name", primary, secondary),
        reportTextField("Relation to Patient", primary, secondary),
        reportTextField("Relation Number", primary, secondary),
        reportTextField("Report Time", primary, secondary),
        reportTextField("Report Date", primary, secondary),
      ],
      primary,
    );
  }
}
