import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/widgets/performance_widgets.dart';
import 'package:ems_op_room/core/widgets/animation_widgets.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';
import 'package:ems_op_room/core/providers/overview_provider.dart';
import 'package:ems_op_room/presentation/CEO/components/shift_state_card.dart';
import 'package:ems_op_room/presentation/CEO/components/active_missions.dart';
import 'package:ems_op_room/presentation/CEO/components/center_status_card.dart';
import 'package:ems_op_room/core/widgets/fleet_map_widget.dart';

class MainContent extends ConsumerWidget {
  final bool isMobile;
  const MainContent({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewDashboardProvider);

    return overviewAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تعذر تحميل البيانات: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(overviewDashboardProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      data: (map) {
        final activeMissions = List<Map<String, dynamic>>.from(
          (map['active_tasks'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        final centersData = List<Map<String, dynamic>>.from(
          (map['centers'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
        );

        final totalActiveTasks = centersData.fold<int>(
          0,
          (sum, center) => sum + ((center['active_total'] as int?) ?? 0),
        );
        final totalCompletedTasks = centersData.fold<int>(
          0,
          (sum, center) => sum + ((center['completed_total'] as int?) ?? 0),
        );
        final totalVehicles = centersData.fold<int>(
          0,
          (sum, center) => sum + ((center['vehicle_count'] as int?) ?? 0),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                FadeInAnimation(
                  child: AppCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSectionHeader(
                          title: 'ملخص تشغيلي مباشر',
                          subtitle: 'مؤشرات سريعة تساعد الإدارة على تقييم الجاهزية والاستجابة',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'تحديث حي',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            AppMetricChip(
                              label: 'المهام النشطة',
                              value: '$totalActiveTasks',
                              icon: Icons.local_fire_department_rounded,
                              color: Colors.redAccent,
                            ),
                            AppMetricChip(
                              label: 'المهام المكتملة',
                              value: '$totalCompletedTasks',
                              icon: Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            AppMetricChip(
                              label: 'المركبات',
                              value: '$totalVehicles',
                              icon: Icons.local_shipping_rounded,
                            ),
                            AppMetricChip(
                              label: 'البلاغات الجارية',
                              value: '${activeMissions.length}',
                              icon: Icons.notifications_active_rounded,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // أ. المهام النشطة والخريطة
                FadeInAnimation(
                  child: isMobile
                      ? Column(
                          children: [
                            SizedBox(height: 300, child: ActiveMissionsCard(activeMissions: activeMissions)),
                            const SizedBox(height: 16),
                            const FleetMapWidget(height: 300),
                          ],
                        )
                      : SizedBox(
                          height: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: ActiveMissionsCard(activeMissions: activeMissions),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                flex: 2,
                                child: FleetMapWidget(height: 300),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // ب. حالة المراكز
                FadeInAnimation(
                  child: OptimizedGridView<Map<String, dynamic>>(
                    items: centersData,
                    crossAxisCount: isMobile ? 1 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.4 : 1.3,
                    shrinkWrap: true,
                    itemBuilder: (context, center, index) {
                      return CenterStatusCard(center: center);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ت. إحصائيات المناوبات
                const FadeInAnimation(
                  child: ShiftStatsCard(),
                ),
              ],
        );
      },
    );
  }
}
