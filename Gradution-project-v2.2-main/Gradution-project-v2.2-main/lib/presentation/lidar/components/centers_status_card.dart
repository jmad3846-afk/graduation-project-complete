import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';

class CentersStatusCard extends ConsumerWidget {
  final bool isDesktop;
  const CentersStatusCard({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sectorDashboardProvider);

    final listView = async.when(
      data: (map) {
        final centers = (map['centers'] as List<dynamic>?) ?? [];
        return ListView.builder(
          itemCount: centers.length,
          shrinkWrap: !isDesktop,
          physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final center = centers[index] as Map<String, dynamic>;
            return ListTile(
              title: Text(center['name']?.toString() ?? ''),
              subtitle: Text(
                'فرق(مركبات): ${center['vehicle_count'] ?? 0} | نشطة: ${center['active_cases_count'] ?? 0} | منتظرة: ${center['pending_cases_count'] ?? 0}',
              ),
              trailing: Icon(
                Icons.circle,
                size: 12,
                color: Theme.of(context).primaryColor,
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
            Text('خطأ في تحميل حالة المراكز: $e'),
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
              'حالة المراكز',
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
