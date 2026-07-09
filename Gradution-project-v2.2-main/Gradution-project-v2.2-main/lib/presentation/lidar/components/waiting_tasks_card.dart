import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:ems_op_room/core/providers/data_providers.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';

class WaitingTasksCard extends ConsumerWidget {
  final bool isDesktop;
  const WaitingTasksCard({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المهام المنتظرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ref.watch(sectorDashboardProvider).when(
                data: (map) {
                  final waitingTasks = (map['pending_tasks'] as List<dynamic>?) ?? [];
                  if (waitingTasks.isEmpty) {
                    return const Center(child: Text("لا توجد مهام منتظرة"));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(sectorDashboardProvider),
                    child: ListView.builder(
                      itemCount: waitingTasks.length,
                      shrinkWrap: !isDesktop,
                      physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final task = waitingTasks[index] as Map<String, dynamic>;
                        final callerName = task['caller'] != null ? (task['caller']['name']?.toString() ?? '') : '';
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 6,
                          ),
                          title: Text(callerName),
                          subtitle: Text(
                            '${task['triage_code'] ?? ''} • ${task['created_at'] ?? ''} • ${task['latitude'] ?? ''}, ${task['longitude'] ?? ''}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              Text(task['id']?.toString() ?? ''),
                              TextButton(
                                onPressed: () {
                                  _showTaskDetailsDialog(context, task);
                                },
                                child: const Text('عرض التفاصيل'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _showCenterSelectionSheet(context, ref, task);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                child: const Text('تحريك مركز'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('خطأ في تحميل المهام: $e'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(sectorDashboardProvider),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(
    BuildContext context,
    dynamic task,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('مهمة ${task['id']?.toString() ?? ''}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المعرف: ${task['id']?.toString() ?? ''}'),
              const SizedBox(height: 8),
              Text('المتصل: ${task['caller'] != null ? (task['caller']['name']?.toString() ?? '') : ''}'),
              const SizedBox(height: 8),
              Text('الموقع: ${task['latitude'] ?? ''}, ${task['longitude'] ?? ''}'),
              const SizedBox(height: 8),
              Text('الحالة: ${task['status'] ?? ''}'),
              const SizedBox(height: 8),
              Text('رمز الترياج: ${task['triage_code'] ?? ''}'),
              const SizedBox(height: 8),
              Text('أنشئت: ${task['created_at'] ?? ''}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showCenterSelectionSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic task,
  ) {
    final centers = ['100', '110', '140', '115'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              'اختر المركز لتحريك المهمة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...centers.map(
              (centerCode) => ListTile(
                title: Text('مركز $centerCode', textDirection: TextDirection.rtl),
                onTap: () {
                  // FUTURE_INTEGRATION_ASSUMPTION: Need real implementation to move task
                  // ref.read(caseServiceProvider).assignCenter(task.id, int.parse(centerCode));
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

}
