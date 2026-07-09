import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';
import '../data/status_chip.dart';

class ActiveTasksCard extends ConsumerWidget {
  final bool isDesktop;

  const ActiveTasksCard({super.key, required this.isDesktop});

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
        return Row(
          children: [
                Expanded(flex: 2, child: Text(task['id']?.toString() ?? '')),
                Expanded(flex: 3, child: Text(task['center'] != null ? (task['center']['name']?.toString() ?? '') : '')),
                Expanded(flex: 2, child: Text(task['status']?.toString() ?? '')),
                if (isDesktop)
                  Expanded(flex: 3, child: Text(task['destination_hospital']?.toString() ?? '')),
                Expanded(
                  flex: 2,
                  child: statusChip(task['status']?.toString() ?? '', Colors.blue),
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
