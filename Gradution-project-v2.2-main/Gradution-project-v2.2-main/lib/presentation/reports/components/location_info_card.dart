import 'package:flutter/material.dart';
import 'report_shared_widgets.dart';

class LocationInfoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final ValueNotifier<String> transferTypeNotifier;

  static const List<String> transferTypes = [
    'Hospital-to-Hospital',
    'Dispensary-to-Hospital',
    'Clinic-to-Hospital',
    'Home-to-Hospital',
    'Hospital-to-Home',
  ];

  const LocationInfoCard({
    required this.primary,
    required this.secondary,
    required this.transferTypeNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return infoCard(
      "Location and Destination",
      [
        ValueListenableBuilder<String>(
          valueListenable: transferTypeNotifier,
          builder: (context, value, _) => DropdownButtonFormField<String>(
            initialValue: transferTypes.contains(value) ? value : null,
            decoration: InputDecoration(
              labelText: 'Transfer Type',
              labelStyle: TextStyle(color: secondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            style: TextStyle(color: primary),
            items: transferTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) {
              if (v != null) transferTypeNotifier.value = v;
            },
          ),
        ),
      ],
      primary,
    );
  }
}
