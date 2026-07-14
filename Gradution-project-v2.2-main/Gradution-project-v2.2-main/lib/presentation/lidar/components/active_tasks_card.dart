import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';
import '../data/status_chip.dart';

class ActiveTasksCard extends ConsumerWidget {
  final bool isDesktop;

  const ActiveTasksCard({super.key, required this.isDesktop});

  // Matches the field order Radio fills the movement log in (mission_row.dart),
  // last-set-wins: the most recently reached step is the case's current status.
  static const _movementSteps = [
    ['arrive_center', 'وصول (مركز)'],
    ['depart_center', 'انطلاق (مركز)'],
    ['arrive_hospital', 'وصول (مشفى)'],
    ['depart_hospital', 'انطلاق (مشفى)'],
    ['arrive_patient', 'وصول (مريض)'],
    ['depart_patient', 'انطلاق (مريض)'],
  ];

  /// The Leader-facing status label: the latest movement-log timestamp Radio
  /// has set, with its time, e.g. "انطلاق (مريض) 14:32" — falls back to the
  /// coarse case status if Radio hasn't logged anything yet.
  static String _currentStatusLabel(Map<String, dynamic> task) {
    final movementLog = task['movement_log'] as Map<String, dynamic>?;

    if (movementLog != null) {
      for (final step in _movementSteps) {
        final value = movementLog[step[0]];
        if (value != null && value.toString().isNotEmpty) {
          return '${step[1]} ${value.toString()}';
        }
      }
    }

    return task['status']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sectorDashboardProvider);

    final listView = async.when(
      data: (map) {
        final activeTasks = (map['active_tasks'] as List<dynamic>?) ?? [];
        return ListView.separated(
          itemCount: activeTasks.length,
          separatorBuilder: (_, __) => const Divider(),
          shrinkWrap: !isDesktop,
          physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final task = activeTasks[index] as Map<String, dynamic>;
            final currentStatus = _currentStatusLabel(task);
        return Row(
          children: [
                Expanded(flex: 2, child: Text(task['id']?.toString() ?? '')),
                Expanded(flex: 3, child: Text(task['center'] != null ? (task['center']['name']?.toString() ?? '') : '')),
                Expanded(flex: 2, child: Text(currentStatus)),
                if (isDesktop)
                  Expanded(flex: 3, child: Text(task['destination_hospital']?.toString() ?? '')),
                Expanded(
                  flex: 2,
                  child: statusChip(currentStatus, Colors.blue),
                ),
                Expanded(flex: 2, child: Text(task['created_at']?.toString() ?? '')),
          ],
        );
          },
        );
      },
      loading: () => ListView(
        shrinkWrap: !isDesktop,
        physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
        children: const [Center(child: CircularProgressIndicator())],
      ),
      error: (e, st) => ListView(
        shrinkWrap: !isDesktop,
        physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
        children: [
          Center(child: Text('Error loading active tasks: $e')),
        ],
      ),
    );

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المهام النشطة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (isDesktop)
              Expanded(child: listView)
            else
              SizedBox(
                height: 300,
                child: RefreshIndicator(
                  onRefresh: () async => ref.refresh(sectorDashboardProvider),
                  child: listView,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
