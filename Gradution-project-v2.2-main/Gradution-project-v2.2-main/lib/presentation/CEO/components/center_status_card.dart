// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CenterStatusCard extends StatelessWidget {
  final Map<String, dynamic> center;
  const CenterStatusCard({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final activeByTriage = Map<String, dynamic>.from(center['active_by_triage'] as Map? ?? {});
    final completedByTriage = Map<String, dynamic>.from(center['completed_by_triage'] as Map? ?? {});

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(right: BorderSide(color: Theme.of(context).primaryColor, width: 4.0)),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Text(center['name']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('مهام نشطة: ${center['active_total'] ?? 0}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text('نشطة', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textDirection: TextDirection.rtl),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            textDirection: TextDirection.rtl,
            children: [
              _buildTeamStat(context, 'أحمر', activeByTriage['red'] ?? 0, Colors.red),
              _buildTeamStat(context, 'أصفر', activeByTriage['yellow'] ?? 0, Colors.amber),
              _buildTeamStat(context, 'أخضر', activeByTriage['green'] ?? 0, Colors.green),
            ],
          ),
          const SizedBox(height: 10),
          Text('مكتملة (${center['completed_total'] ?? 0})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textDirection: TextDirection.rtl),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            textDirection: TextDirection.rtl,
            children: [
              _buildTeamStat(context, 'أحمر', completedByTriage['red'] ?? 0, Colors.red),
              _buildTeamStat(context, 'أصفر', completedByTriage['yellow'] ?? 0, Colors.amber),
              _buildTeamStat(context, 'أخضر', completedByTriage['green'] ?? 0, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color.withOpacity(0.7))),
      ],
    );
  }
}
