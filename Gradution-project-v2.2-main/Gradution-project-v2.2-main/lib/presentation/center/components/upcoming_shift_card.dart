import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/upcoming_shift_model.dart';
import '../../../core/providers/center_shift_provider.dart';
import '../../../core/providers/center_selection_provider.dart';
import '../../../core/providers/auth_provider.dart';

class UpcomingShiftCard extends ConsumerStatefulWidget {
  const UpcomingShiftCard({super.key});

  @override
  ConsumerState<UpcomingShiftCard> createState() => _UpcomingShiftCardState();
}

class _UpcomingShiftCardState extends ConsumerState<UpcomingShiftCard> {
  bool get _isAdmin => ref.read(authNotifierProvider).user?.role == 'admin';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadForCurrentSelection);
    ref.listenManual<int?>(selectedCenterIdProvider, (previous, next) {
      if (previous != next) _loadForCurrentSelection();
    });
  }

  void _loadForCurrentSelection() {
    if (_isAdmin) {
      final centerId = ref.read(selectedCenterIdProvider);
      if (centerId == null) {
        ref.read(centerShiftProvider.notifier).clearForNoCenter();
        return;
      }
      ref.read(centerShiftProvider.notifier).loadUpcomingShift(centerId: centerId);
    } else {
      ref.read(centerShiftProvider.notifier).loadUpcomingShift();
    }
  }

  static const _roleLabels = {
    'leader': 'القائد',
    'scout': 'الكشاف',
    'paramedic': 'المسعف',
  };

  Future<void> _handleCheckIn(ShiftAssigneeModel assignee) async {
    final ok = await ref.read(centerShiftProvider.notifier).checkIn(assignee.assignmentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'تم تسجيل دخول ${assignee.name}' : 'فشل تسجيل الدخول')),
    );
  }

  Future<void> _handleNextShift() async {
    await ref.read(centerShiftProvider.notifier).loadNextShift();
  }

  Widget _buildAssigneeRow(String role, ShiftAssigneeModel? assignee) {
    final label = _roleLabels[role] ?? role;
    if (assignee == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text('$label: غير معين', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text('$label: ${assignee.name}')),
          if (assignee.isDone)
            const Chip(
              label: Text('تم الدخول', style: TextStyle(fontSize: 11)),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
              visualDensity: VisualDensity.compact,
            )
          else
            TextButton.icon(
              onPressed: () => _handleCheckIn(assignee),
              icon: const Icon(Icons.login, size: 16),
              label: const Text('تسجيل الدخول'),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(ShiftTeamModel team, bool showLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'الفريق ${team.team}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
        _buildAssigneeRow('leader', team.leader),
        _buildAssigneeRow('scout', team.scout),
        _buildAssigneeRow('paramedic', team.paramedic),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(centerShiftProvider);
    final isAdmin = ref.watch(authNotifierProvider).user?.role == 'admin';
    final noCenterSelected = isAdmin && ref.watch(selectedCenterIdProvider) == null;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗓️ المناوبة القادمة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            if (noCenterSelected)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('اختر مركزاً لعرض المناوبات', style: TextStyle(color: Colors.grey)),
              )
            else if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.shift == null || state.shift!.teams.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('لا توجد مناوبة قادمة', style: TextStyle(color: Colors.grey)),
              )
            else ...[
              ...state.shift!.teams.map(
                (team) => _buildTeamSection(team, state.shift!.teams.length > 1),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.shift!.allCheckedIn ? _handleNextShift : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('المناوبة التالية'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
