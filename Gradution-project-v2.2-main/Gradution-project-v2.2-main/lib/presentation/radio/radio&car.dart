import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'components/header_bar.dart';
import 'components/mission_row.dart';

class RadioCarPage extends ConsumerStatefulWidget {
  const RadioCarPage({super.key});

  @override
  ConsumerState<RadioCarPage> createState() => _RadioCarPageState();
}

class _RadioCarPageState extends ConsumerState<RadioCarPage> {
  late List<Map<String, String>> _missions;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _missions = _generateRandomMissions(20);
  }

  List<Map<String, String>> _generateRandomMissions(int count) {
    final names = ['خالد المحمد', 'فاطمة العلي', 'محمد السعيد', 'نورة اليوسف', 'علياء حسين', 'باسم زكي'];
    final statuses = ['Red', 'Yellow', 'Green'];
    final teamLeaders = ['خالد', 'فاطمة', 'علي', 'نورة'];
    final hospital = ['مشفى الشام', 'الرازي', 'الأمل', 'الجامعي'];
    final reasons = ['رفض المريض التام للانتقال', 'تم تأكيد الوفاة في الموقع', 'عدم توفر سرير'];

    return List.generate(count, (index) {
      final didTransfer = _random.nextBool();
      final status = statuses[_random.nextInt(statuses.length)];

      return {
        'id': 'M${100 + index}',
        'name': '${names[_random.nextInt(names.length)]} (${index + 1})',
        'status': status,
        'center': (100 + _random.nextInt(30)).toString(),
        'code': (100 + _random.nextInt(99)).toString(),
        'teamLeader': teamLeaders[_random.nextInt(teamLeaders.length)],
        'toPatientTime': _randomTime(),
        'atPatientTime': _randomTime(),
        'toHospitalTime': didTransfer ? _randomTime() : '',
        'atHospitalTime': didTransfer ? _randomTime() : '',
        'toCenterTime': _randomTime(),
        'atCenterTime': _randomTime(),
        'hospital': didTransfer ? hospital[_random.nextInt(hospital.length)] : '',
        'reasonForNoTransfer': !didTransfer ? reasons[_random.nextInt(reasons.length)] : '',
        'transferStatus': didTransfer ? 'تم النقل' : 'لم يتم النقل',
      };
    });
  }

  String _randomTime() {
    if (_random.nextDouble() < 0.2) return '';
    final h = _random.nextInt(15) + 8;
    final m = _random.nextInt(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _updateMission(String missionId, String key, String value) {
    final idx = _missions.indexWhere((m) => m['id'] == missionId);
    if (idx != -1) {
      setState(() {
        _missions[idx][key] = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final extraMissions = ref.watch(radioMissionsProvider);
    final allMissions = [..._missions, ...extraMissions];

    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    final missionCounts = allMissions.fold(
        {'Red': 0, 'Yellow': 0, 'Green': 0}, (Map<String, int> acc, m) {
      final status = m['status'] ?? 'Green';
      acc[status] = (acc[status] ?? 0) + 1;
      return acc;
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          HeaderBar(missionCounts: missionCounts, isLargeScreen: isLargeScreen),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Column(
                    children: [
                      Card(
                        color: theme.cardColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                            child: Column(
                              children: allMissions.map((mission) {
                                return MissionRow(
                                  mission: mission,
                                  onUpdate: _updateMission,
                                );
                              }).toList(),
                            ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: isLargeScreen ? 600 : double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.hintColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'عرض جميع المهام',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
