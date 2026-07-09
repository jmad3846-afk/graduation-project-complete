import 'package:flutter/material.dart';

import 'components/active_tasks_card.dart';
import 'components/waiting_tasks_card.dart';
import 'components/team_status_card.dart';
import 'components/centers_status_card.dart';

class Lidar extends StatelessWidget {
  const Lidar({super.key});

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
                          Expanded(flex: 3,
                            child: TeamStatusCard(isDesktop: true),
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
                          Expanded(flex:2,child: TeamStatusCard(isDesktop: false)),
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
