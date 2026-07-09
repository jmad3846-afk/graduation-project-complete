// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';


class ActiveMissionsCard extends StatelessWidget {
  final List<Map<String, String>> activeMissions;
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
            child: ListView.builder(
              itemCount: activeMissions.length,
              itemBuilder: (context, index) {
                final mission = activeMissions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('حادث سير - #${mission['id']}', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            Text(mission['location']!, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
}