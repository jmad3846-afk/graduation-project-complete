import 'package:flutter/material.dart';

class CenterStatsCard extends StatefulWidget {
  const CenterStatsCard({super.key});

  @override
  State<CenterStatsCard> createState() => _CenterStatsCardState();
}

class _CenterStatsCardState extends State<CenterStatsCard> {
  String period = 'currentDay';

  final Map<String, Map<String, int>> stats = {
    'currentDay': {'missions': 4, 'shifts': 2},
    'currentWeek': {'missions': 25, 'shifts': 14},
    'currentMonth': {'missions': 110, 'shifts': 60},
  };

  @override
  Widget build(BuildContext context) {
    final data = stats[period]!;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 إحصائيات المركز',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            DropdownButtonFormField<String>(
              initialValue: period,
              items: const [
                DropdownMenuItem(value: 'currentDay', child: Text('اليوم الحالي')),
                DropdownMenuItem(value: 'currentWeek', child: Text('هذا الأسبوع')),
                DropdownMenuItem(value: 'currentMonth', child: Text('هذا الشهر')),
              ],
              onChanged: (v) => setState(() => period = v!),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _stat('إجمالي المهمات', data['missions']!, Colors.deepOrange),
                _stat('عدد المناوبات', data['shifts']!, Colors.blue),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(fontSize: 24, color: color)),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
