import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/my_schedule_model.dart';
import '../core/providers/data_providers.dart';

class MyScheduleView extends ConsumerWidget {
  const MyScheduleView({super.key});

  static const _monthNames = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String _formatDay(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  Widget _compensationBanner(MyScheduleModel schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE52E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Compensation',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${schedule.compensation} SYP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${schedule.shiftCount} shifts • ${_monthNames[schedule.month.clamp(1, 12)]} ${schedule.year}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(myScheduleWithCompensationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myScheduleWithCompensationProvider);
        },
        child: scheduleAsync.when(
          data: (schedule) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _compensationBanner(schedule),
                if (schedule.assignments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No shifts assigned yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...schedule.assignments.map((a) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            a.isDone ? Icons.check_circle : Icons.event_available,
                            color: a.isDone ? Colors.green : const Color(0xFFE52E2E),
                          ),
                          title: Text(a.center.isEmpty ? '—' : a.center),
                          subtitle: Text(
                              '${_formatDay(a.date)}  •  ${a.shiftType}  •  ${a.role}'),
                          trailing: Chip(
                            label: Text(
                              a.isDone ? 'Attended' : 'Selected',
                              style: const TextStyle(fontSize: 11, color: Colors.white),
                            ),
                            backgroundColor: a.isDone ? Colors.green : Colors.grey,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 100),
              Center(child: Text('Failed to load schedule: $err')),
            ],
          ),
        ),
      ),
    );
  }
}
