// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';


class ShiftStatsCard extends StatefulWidget {
  const ShiftStatsCard({super.key});

  @override
  State<ShiftStatsCard> createState() => _ShiftStatsCardState();
}

class _ShiftStatsCardState extends State<ShiftStatsCard> {
  String _mode = 'summary';
  String _period = 'currentMonth';
  String _searchTerm = '';

  final Map<String, dynamic> stats = const {
    'summary': {
      'currentDay': {'shifts': 10, 'missions': 20, 'responders': 15},
      'currentMonth': {'shifts': 150, 'missions': 300, 'responders': 45},
      'lastMonth': {'shifts': 145, 'missions': 280, 'responders': 43},
      'currentYear': {'shifts': 1800, 'missions': 3500, 'responders': 60},
    },
    'individual': {
      'خالد محمد': {'lastMonth': 18, 'currentMonth': 15, 'total': 210, 'currentYear': 200},
      'فاطمة أحمد': {'lastMonth': 20, 'currentMonth': 19, 'total': 240, 'currentYear': 230},
    }
  };

  @override
  Widget build(BuildContext context) {
    final currentStats = stats['summary']?[_period] ?? {};
    final searchedRescuer = stats['individual']?[_searchTerm];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 4.0)),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إحصائيات المناوبات والمهمات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('ملخص الفترة'),
                onPressed: () => setState(() => _mode = 'summary'),
                style: TextButton.styleFrom(
                  foregroundColor: _mode == 'summary' ? Theme.of(context).primaryColor : Colors.grey,
                  side: _mode == 'summary' ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('بحث عن مسعف'),
                onPressed: () => setState(() => _mode = 'individual'),
                style: TextButton.styleFrom(
                  foregroundColor: _mode == 'individual' ? Theme.of(context).primaryColor : Colors.grey,
                  side: _mode == 'individual' ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_mode == 'summary')
            _buildSummary(currentStats),
          if (_mode == 'individual')
            _buildIndividual(searchedRescuer),
        ],
      ),
    );
  }

  Widget _buildSummary(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'اختر الفترة',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          initialValue: _period,
          items: const [
            {'value': 'currentDay', 'label': 'هذا اليوم'},
            {'value': 'currentShift', 'label': 'هذه المناوبة'},
            {'value': 'currentWeek', 'label': 'هذا الأسبوع'},
            {'value': 'currentMonth', 'label': 'هذا الشهر'},
            {'value': 'lastMonth', 'label': 'الشهر السابق'},
            {'value': 'currentYear', 'label': 'هذا العام'},
          ].map((item) => DropdownMenuItem(value: item['value'], child: Text(item['label']!))).toList(),
          onChanged: (value) => setState(() => _period = value!),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatBox(context, 'إجمالي المناوبات', stats['shifts'] ?? 0, Colors.red),
            _buildStatBox(context, 'عدد المهمات', stats['missions'] ?? 0, Colors.deepOrange),
            _buildStatBox(context, 'عدد المسعفين المناوبين', stats['responders'] ?? 0, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text('$count', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndividual(Map<String, dynamic>? rescuer) {
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'ابحث باسم المسعف (مثال: خالد محمد)',
            border: OutlineInputBorder(),
            isDense: true,
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _searchTerm = value.trim()),
        ),
        const SizedBox(height: 16),
        if (rescuer != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('نتائج المسعف: $_searchTerm', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat('هذا الشهر', rescuer['currentMonth']),
                      _buildDetailStat('الشهر الماضي', rescuer['lastMonth']),
                      _buildDetailStat('هذا العام', rescuer['currentYear']),
                      _buildDetailStat('العدد الكلي', rescuer['total']),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('يرجى إدخال اسم المسعف للبحث عن إحصائياته.', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  Widget _buildDetailStat(String title, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
