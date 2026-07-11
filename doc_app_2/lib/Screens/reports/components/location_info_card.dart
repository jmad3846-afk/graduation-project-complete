import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class LocationInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const LocationInfoCard(this.primary, this.secondary, {super.key});

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Location and Destination",
      [
        reportTextField("Location", primary, secondary),
        reportTextField("Supervising Doctor", primary, secondary),
        reportTextField("Doctor's Phone", primary, secondary),
        reportTextField("Going To", primary, secondary),
        reportTextField("Receiving Doctor", primary, secondary),
        reportTextField("Hospital Phone", primary, secondary),
      ],
      primary,
    );
  }
}
