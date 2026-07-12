// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ActiveMissionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> activeMissions;
  const ActiveMissionsCard({super.key, required this.activeMissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: const Border(right: BorderSide(color: Colors.red, width: 4.0)),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المهام النشطة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
          const Divider(),
          Expanded(
            child: activeMissions.isEmpty
                ? const Center(child: Text('لا توجد مهام نشطة', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: activeMissions.length,
              itemBuilder: (context, index) {
                final mission = activeMissions[index];
                final center = mission['center'] as Map<String, dynamic>?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('حالة #${mission['id']}', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            Text(
                              center?['name']?.toString() ?? mission['destination_hospital']?.toString() ?? '',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showDetailsDialog(context, mission),
                        child: const Text('تفاصيل'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> mission) {
    final center = mission['center'] as Map<String, dynamic>?;
    final caller = mission['caller'] as Map<String, dynamic>?;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مهمة ${mission['id']?.toString() ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${mission['status'] ?? ''}'),
            const SizedBox(height: 8),
            Text('رمز الترياج: ${mission['triage_code'] ?? ''}'),
            const SizedBox(height: 8),
            Text('المركز: ${center?['name'] ?? ''}'),
            const SizedBox(height: 8),
            Text('المتصل: ${caller?['name'] ?? ''}'),
            const SizedBox(height: 8),
            Text('المستشفى الوجهة: ${mission['destination_hospital'] ?? ''}'),
            const SizedBox(height: 8),
            Text('أنشئت: ${mission['created_at'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
