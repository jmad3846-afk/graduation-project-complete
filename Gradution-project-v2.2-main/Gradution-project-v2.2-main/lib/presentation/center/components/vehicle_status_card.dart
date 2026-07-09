// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class VehicleStatusCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleStatusCard({super.key, required this.vehicle});

  Color _statusColor(String status) {
    if (status.contains('مهمة') || status.contains('أحمر')) return Colors.red;
    if (status.contains('متاح')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(vehicle['status']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مركبة ${vehicle['id']} (${vehicle['type']})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'السائق: ${vehicle['driver']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vehicle['status'],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'الوصول المتوقع: ${vehicle['eta']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
