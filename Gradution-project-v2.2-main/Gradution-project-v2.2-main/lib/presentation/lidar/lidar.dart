import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/service_providers.dart';
import 'package:ems_op_room/core/providers/sector_dashboard_provider.dart';

import 'package:ems_op_room/core/widgets/fleet_map_widget.dart';
import 'components/active_tasks_card.dart';
import 'components/waiting_tasks_card.dart';
import 'components/centers_status_card.dart';

class Lidar extends ConsumerStatefulWidget {
  const Lidar({super.key});

  @override
  ConsumerState<Lidar> createState() => _LidarState();
}

class _LidarState extends ConsumerState<Lidar> {
  StreamSubscription? _caseCreatedSubscription;

  @override
  void initState() {
    super.initState();
    // A new report submitted anywhere (POST /cases) is broadcast on the
    // private cases.new channel; refetch the dashboard so it shows up in
    // Pending Tasks without the leader having to manually refresh.
    _caseCreatedSubscription = ref.read(wsProvider).onCaseCreated.listen((_) {
      ref.invalidate(sectorDashboardProvider);
    });
  }

  @override
  void dispose() {
    _caseCreatedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'غرفة عمليات Lidar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLargeScreen
                // ================= DESKTOP =================
                ? Column(
                  children: [
                    Expanded(flex: 3, child: ActiveTasksCard(isDesktop: true)),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: WaitingTasksCard(isDesktop: true),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(flex: 3,
                            child: FleetMapWidget(height: double.infinity),
                          ),
                          const SizedBox(width: 16),
                          Expanded(flex:3,
                            child: CentersStatusCard(isDesktop: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                // ================= MOBILE =================
                : SingleChildScrollView(
                  child: Column(
                    children: const [
                      ActiveTasksCard(isDesktop: false),
                      SizedBox(height: 16),
                      WaitingTasksCard(isDesktop: false),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(flex:2,child: FleetMapWidget(height: 300)),
                          SizedBox(width: 16),
                          Expanded(flex:2,child: CentersStatusCard(isDesktop: false)),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
