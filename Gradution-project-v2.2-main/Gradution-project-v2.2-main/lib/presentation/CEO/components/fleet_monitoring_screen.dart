// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/service_providers.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';
import 'package:ems_op_room/core/widgets/fleet_map_widget.dart';
import '../../lidar/components/active_tasks_card.dart';

class FleetMonitoringPage extends ConsumerStatefulWidget {
  const FleetMonitoringPage({super.key});

  @override
  ConsumerState<FleetMonitoringPage> createState() => _FleetMonitoringPageState();
}

class _FleetMonitoringPageState extends ConsumerState<FleetMonitoringPage> {
  StreamSubscription? _caseCreatedSubscription;
  StreamSubscription? _caseStatusUpdatedSubscription;

  @override
  void initState() {
    super.initState();
    // Same live-update wiring as the Leader (Lidar) dashboard: a new case or
    // any Radio-set movement-log timestamp refetches the shared active-tasks
    // data so this screen stays in sync with it in real time.
    _caseCreatedSubscription = ref.read(wsProvider).onCaseCreated.listen((_) {
      ref.invalidate(sectorDashboardProvider);
    });
    _caseStatusUpdatedSubscription = ref.read(wsProvider).onCaseStatusUpdated.listen((_) {
      ref.invalidate(sectorDashboardProvider);
    });
  }

  @override
  void dispose() {
    _caseCreatedSubscription?.cancel();
    _caseStatusUpdatedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراقبة الأسطول'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            // منطقة الخريطة (الجزء العلوي)
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: FleetMapWidget(height: double.infinity),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // المهام النشطة (نفس بيانات واجهة القائد) — مباشرة أسفل الخريطة
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ActiveTasksCard(isDesktop: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}