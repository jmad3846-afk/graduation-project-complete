// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/center_selection_provider.dart';
import 'package:ems_op_room/core/providers/overview_provider.dart';

class ShiftStatsCard extends ConsumerStatefulWidget {
  const ShiftStatsCard({super.key});

  @override
  ConsumerState<ShiftStatsCard> createState() => _ShiftStatsCardState();
}

class _ShiftStatsCardState extends ConsumerState<ShiftStatsCard> {
  int? _centerId;
  String _period = 'day';

  static const _periods = [
    {'value': 'day', 'label': 'اليوم'},
    {'value': 'week', 'label': 'هذا الأسبوع'},
    {'value': 'month', 'label': 'هذا الشهر'},
  ];

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(centersListProvider);

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
          centersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('تعذر تحميل قائمة المراكز: $e'),
            ),
            data: (centers) {
              if (centers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد مراكز'),
                );
              }
              _centerId ??= centers.first.id;
              return _buildFilters(centers);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<dynamic> centers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'المركز',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                initialValue: _centerId,
                items: centers
                    .map((c) => DropdownMenuItem<int>(value: c.id as int, child: Text(c.name as String)))
                    .toList(),
                onChanged: (value) => setState(() => _centerId = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الفترة',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                initialValue: _period,
                items: _periods
                    .map((p) => DropdownMenuItem(value: p['value'], child: Text(p['label']!)))
                    .toList(),
                onChanged: (value) => setState(() => _period = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_centerId != null) _buildStats(_centerId!),
      ],
    );
  }

  Widget _buildStats(int centerId) {
    final statsAsync = ref.watch(
      centerStatisticsProvider(CenterStatsParams(centerId: centerId, period: _period)),
    );

    return statsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('تعذر تحميل الإحصائيات: $e'),
      ),
      data: (stats) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox(context, 'عدد المناوبات', (stats['shifts'] as int?) ?? 0, Colors.red),
          _buildStatBox(context, 'عدد المهام', (stats['tasks'] as int?) ?? 0, Colors.deepOrange),
        ],
      ),
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
}
