import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class LocationInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  // Controllers for each field
  final TextEditingController locationController;
  final TextEditingController supervisingDoctorController;
  final TextEditingController doctorPhoneController;
  final TextEditingController goingToController;
  final TextEditingController receivingDoctorController;
  final TextEditingController hospitalPhoneController;

  const LocationInfoCard({
    required this.primary,
    required this.secondary,
    required this.locationController,
    required this.supervisingDoctorController,
    required this.doctorPhoneController,
    required this.goingToController,
    required this.receivingDoctorController,
    required this.hospitalPhoneController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Location and Destination",
      [
        reportTextField("Location", primary, secondary, controller: locationController),
        reportTextField("Supervising Doctor", primary, secondary, controller: supervisingDoctorController),
        reportTextField("Doctor's Phone", primary, secondary, controller: doctorPhoneController),
        reportTextField("Going To", primary, secondary, controller: goingToController),
        reportTextField("Receiving Doctor", primary, secondary, controller: receivingDoctorController),
        reportTextField("Hospital Phone", primary, secondary, controller: hospitalPhoneController),
      ],
      primary,
    );
  }
}


