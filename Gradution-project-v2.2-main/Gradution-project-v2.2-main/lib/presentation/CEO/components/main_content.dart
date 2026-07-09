import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/widgets/performance_widgets.dart';
import 'package:ems_op_room/core/widgets/animation_widgets.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';
import 'package:ems_op_room/presentation/CEO/components/shift_state_card.dart';
import 'package:ems_op_room/presentation/CEO/components/active_missions.dart';
import 'package:ems_op_room/presentation/CEO/components/center_status_card.dart';
import 'package:ems_op_room/presentation/CEO/components/map_placeholder.dart' hide CenterStatusCard;

class MainContent extends ConsumerWidget {
  final bool isMobile;
  const MainContent({super.key, this.isMobile = false});
  
  final List<Map<String, dynamic>> centersData = const [
    {'name': 'Center 100', 'activeTasks': 3, 'teams': {'active': 12, 'busy': 8, 'available': 15}},
    {'name': 'Center 115', 'activeTasks': 1, 'teams': {'active': 15, 'busy': 11, 'available': 13}},
  ];
  final List<Map<String, String>> activeMissions = const [
    {'id': '0555', 'type': 'حادث مروري', 'location': 'طريق المطار 102'},
    {'id': '0554', 'type': 'شك اشتباه', 'location': 'الرقة شارع دمشق'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalActiveTasks = centersData.fold<int>(
      0,
      (sum, center) => sum + ((center['activeTasks'] as int?) ?? 0),
    );
    final totalTeams = centersData.fold<int>(
      0,
      (sum, center) =>
          sum + (((center['teams'] as Map<String, dynamic>)['active'] as int?) ?? 0),
    );
    final totalAvailable = centersData.fold<int>(
      0,
      (sum, center) =>
          sum +
          (((center['teams'] as Map<String, dynamic>)['available'] as int?) ?? 0),
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
                      label: 'الفرق الميدانية',
                      value: '$totalTeams',
                      icon: Icons.groups_rounded,
                    ),
                    AppMetricChip(
                      label: 'الفرق المتاحة',
                      value: '$totalAvailable',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
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
                    ActiveMissionsCard(activeMissions: activeMissions),
                    const SizedBox(height: 16),
                    const MapPlaceholder(),
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
                        child: MapPlaceholder(),
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
            childAspectRatio: isMobile ? 3.0 : 2.5,
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
  }
}
