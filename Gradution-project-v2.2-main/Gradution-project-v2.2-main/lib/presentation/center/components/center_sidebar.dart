import 'package:flutter/material.dart';
import 'center_picker.dart';
import 'upcoming_shift_card.dart';
import 'center_stats_card.dart';
import 'center_mission_filters.dart';

class CenterSidebar extends StatelessWidget {
  const CenterSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CenterPicker(),
        SizedBox(height: 20),
        UpcomingShiftCard(),
        SizedBox(height: 20),
        CenterStatsCard(),
        SizedBox(height: 20),
        CenterMissionFilters(),
      ],
    );
  }
}
