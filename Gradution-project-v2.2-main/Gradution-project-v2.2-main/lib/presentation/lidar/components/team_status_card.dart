import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';

class TeamStatusCard extends ConsumerWidget {
  final bool isDesktop;
  const TeamStatusCard({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sectorDashboardProvider);

    final listView = async.when(
      data: (map) {
        final teams = (map['teams'] as List<dynamic>?) ?? [];
        return ListView.builder(
          itemCount: teams.length,
          shrinkWrap: !isDesktop,
          physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final team = teams[index] as Map<String, dynamic>;
            final color = Theme.of(context).primaryColor;
            return ListTile(
              dense: true,
              title: Text(team['name']?.toString() ?? ''),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${team['active'] ?? 0} / ${team['available'] ?? 0}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('خطأ في تحميل حالة الفرق: $e'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(sectorDashboardProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
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
              'حالة الفرق',
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
