// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('تتبع حي للمركبات (منطقة الخريطة)'),
    );
  }
}

class CenterStatusCard extends StatelessWidget {
  final Map<String, dynamic> center;

  const CenterStatusCard({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final teams = center['teams'] as Map<String, int>;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          right: BorderSide(color: Theme.of(context).primaryColor, width: 4.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                center['name'],
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'مهام نشطة: ${center['activeTasks']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            textDirection: TextDirection.rtl,
            children: [
              _buildTeamStat(context, 'نشط', teams['active']!, Colors.red),
              _buildTeamStat(context, 'مشغول', teams['busy']!, Colors.amber),
              _buildTeamStat(
                context,
                'متاح',
                teams['available']!,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color.withOpacity(0.7))),
      ],
    );
  }
}
