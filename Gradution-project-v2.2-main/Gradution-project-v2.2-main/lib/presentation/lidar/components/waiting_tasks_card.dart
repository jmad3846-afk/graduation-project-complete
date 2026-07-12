import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';
import 'package:ems_op_room/core/providers/center_selection_provider.dart';
import 'package:ems_op_room/core/providers/service_providers.dart';

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
    final caseId = task['id'] as int;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (sheetContext, sheetRef, _) {
            final centersAsync = sheetRef.watch(centersListProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'اختر المركز لتحريك المهمة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                centersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, st) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('تعذر تحميل قائمة المراكز'),
                  ),
                  data: (centers) => Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: centers
                          .map(
                            (c) => _CenterAssignTile(
                              centerId: c.id,
                              centerName: c.name,
                              onAssign: () async {
                                try {
                                  await ref.read(caseServiceProvider).assignCenter(caseId, c.id);
                                  ref.invalidate(sectorDashboardProvider);
                                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                } catch (e) {
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                    );
                                  }
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _CenterAssignTile extends ConsumerWidget {
  final int centerId;
  final String centerName;
  final VoidCallback onAssign;

  const _CenterAssignTile({
    required this.centerId,
    required this.centerName,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(_centerTeamStatusProvider(centerId));

    return statusAsync.when(
      loading: () => ListTile(
        title: Text(centerName, textDirection: TextDirection.rtl),
        trailing: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, st) => ListTile(
        title: Text(centerName, textDirection: TextDirection.rtl),
        subtitle: const Text('تعذر التحقق من حالة الفريق', style: TextStyle(color: Colors.grey)),
      ),
      data: (status) {
        final canAssign = status != null && status['can_assign'] == true;
        final teams = status == null ? const [] : (status['teams'] as List<dynamic>? ?? []);
        // Show the ready team if one exists, otherwise the first team, so the
        // leader can see why the center is blocked.
        final shownTeam = status == null
            ? null
            : (status['ready_team'] ?? (teams.isNotEmpty ? teams.first : null));

        return ListTile(
          title: Text(centerName, textDirection: TextDirection.rtl),
          subtitle: status == null
              ? const Text('لا توجد مناوبة اليوم لهذا المركز', style: TextStyle(color: Colors.grey))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canAssign
                          ? (teams.length > 1 ? 'يوجد فريق جاهز (${teams.length} فرق)' : 'الفريق جاهز')
                          : 'الفريق غير مكتمل (القائد/الكشاف)',
                      style: TextStyle(color: canAssign ? Colors.green : Colors.red),
                    ),
                    const SizedBox(height: 4),
                    if (shownTeam != null)
                      Wrap(
                        spacing: 8,
                        children: [
                          _memberChip('القائد', shownTeam['leader']),
                          _memberChip('الكشاف', shownTeam['scout']),
                          _memberChip('المسعف', shownTeam['paramedic']),
                        ],
                      ),
                  ],
                ),
          isThreeLine: status != null,
          enabled: canAssign,
          onTap: canAssign ? onAssign : null,
        );
      },
    );
  }

  Widget _memberChip(String label, dynamic member) {
    final checkedIn = member != null && member['status'] == 'done';
    final present = member != null;
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      avatar: Icon(
        checkedIn ? Icons.check_circle : (present ? Icons.schedule : Icons.remove_circle_outline),
        size: 14,
        color: checkedIn ? Colors.green : (present ? Colors.orange : Colors.grey),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// autoDispose so each time the assign sheet opens it refetches live
// check-in status, instead of serving a stale readiness result from an
// earlier open.
final _centerTeamStatusProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, int>((ref, centerId) async {
  return ref.read(sectorDashboardServiceProvider).fetchTeamStatus(centerId);
});
