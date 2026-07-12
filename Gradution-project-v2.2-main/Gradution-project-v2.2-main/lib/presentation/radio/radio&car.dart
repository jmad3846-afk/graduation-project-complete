import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/radio_cases_provider.dart';
import 'package:ems_op_room/core/providers/service_providers.dart';
import 'components/header_bar.dart';
import 'components/mission_row.dart';
import 'components/finish_case_dialog.dart';

// Keys the mission-row widgets (built for a mock UI) read/write, mapped to
// and from the backend's CaseResource + movement_log shape.
const _kMovementLogFields = {
  'toPatientTime': 'depart_patient',
  'atPatientTime': 'arrive_patient',
  'toHospitalTime': 'depart_hospital',
  'atHospitalTime': 'arrive_hospital',
  'toCenterTime': 'depart_center',
  'atCenterTime': 'arrive_center',
};

class RadioCarPage extends ConsumerStatefulWidget {
  const RadioCarPage({super.key});

  @override
  ConsumerState<RadioCarPage> createState() => _RadioCarPageState();
}

class _RadioCarPageState extends ConsumerState<RadioCarPage> {
  /// Local edits layered on top of the fetched case list so a field the
  /// user just changed doesn't flicker back until the next refresh.
  final Map<int, Map<String, String>> _localOverrides = {};
  final Set<int> _finishingCaseIds = {};

  Map<String, dynamic> _toMission(Map<String, dynamic> c) {
    final movementLog = c['movement_log'] as Map<String, dynamic>?;
    final transported = movementLog?['transported'] as bool?;
    final id = c['id'] as int;

    final mission = <String, String>{
      'id': id.toString(),
      'name': (c['caller']?['name'] as String?) ?? '',
      'status': triageCodeToStatusKey(c['triage_code'] as String?),
      'center': (c['center']?['name'] as String?) ?? '',
      'code': id.toString(),
      'teamLeader': movementLog?['team_leader_name'] as String? ?? '',
      'toPatientTime': movementLog?['depart_patient'] as String? ?? '',
      'atPatientTime': movementLog?['arrive_patient'] as String? ?? '',
      'toHospitalTime': movementLog?['depart_hospital'] as String? ?? '',
      'atHospitalTime': movementLog?['arrive_hospital'] as String? ?? '',
      'toCenterTime': movementLog?['depart_center'] as String? ?? '',
      'atCenterTime': movementLog?['arrive_center'] as String? ?? '',
      'hospital': (c['destination_hospital'] as String?) ?? '',
      'reasonForNoTransfer': movementLog?['reason_not_transported'] as String? ?? '',
      'transferStatus': transported == null
          ? 'تم النقل'
          : (transported ? 'تم النقل' : 'لم يتم النقل'),
    };

    final overrides = _localOverrides[id];
    if (overrides != null) mission.addAll(overrides);
    return mission;
  }

  void _applyLocalOverride(int caseId, String key, String value) {
    setState(() {
      _localOverrides.putIfAbsent(caseId, () => {})[key] = value;
    });
  }

  Future<void> _updateMission(String missionId, String key, String value) async {
    final caseId = int.tryParse(missionId);
    if (caseId == null) return;

    _applyLocalOverride(caseId, key, value);

    final caseService = ref.read(caseServiceProvider);
    try {
      if (_kMovementLogFields.containsKey(key)) {
        final backendField = _kMovementLogFields[key]!;
        await caseService.saveMovementLog(caseId, {
          backendField: value.isEmpty ? null : '$value:00',
        });
      } else if (key == 'teamLeader') {
        await caseService.saveMovementLog(caseId, {'team_leader_name': value});
      } else if (key == 'transferStatus') {
        await caseService.saveMovementLog(caseId, {'transported': value == 'تم النقل'});
      } else if (key == 'reasonForNoTransfer') {
        await caseService.saveMovementLog(caseId, {'reason_not_transported': value});
      } else if (key == 'hospital') {
        await caseService.updateCase(caseId, {'destination_hospital': value});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _finishCase(String missionId) async {
    final caseId = int.tryParse(missionId);
    if (caseId == null) return;

    final photo = await showDialog<FinishCasePhoto>(
      context: context,
      builder: (_) => const FinishCaseDialog(),
    );
    if (photo == null) return;

    setState(() => _finishingCaseIds.add(caseId));
    final caseService = ref.read(caseServiceProvider);
    try {
      await caseService.finishCase(caseId);
      await caseService.uploadArchive(caseId, photo.bytes, photo.filename);
      ref.invalidate(radioCasesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنهاء المهمة وأرشفتها')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _finishingCaseIds.remove(caseId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final casesAsync = ref.watch(radioCasesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: casesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تعذر تحميل المهام: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(radioCasesProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (cases) {
          final missions = cases.map(_toMission).toList();
          final missionCounts = missions.fold(
              {'Red': 0, 'Yellow': 0, 'Green': 0}, (Map<String, int> acc, m) {
            final status = m['status'] ?? 'Green';
            acc[status] = (acc[status] ?? 0) + 1;
            return acc;
          });

          return Column(
            children: [
              HeaderBar(missionCounts: missionCounts, isLargeScreen: isLargeScreen),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(radioCasesProvider),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: Column(
                          children: [
                            if (missions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text('لا توجد مهام نشطة'),
                              )
                            else
                              Card(
                                color: theme.cardColor,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: missions.map((mission) {
                                      final caseId = int.tryParse(mission['id'] ?? '');
                                      return MissionRow(
                                        mission: mission,
                                        onUpdate: _updateMission,
                                        onFinish: () => _finishCase(mission['id']!),
                                        isFinishing: _finishingCaseIds.contains(caseId),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
