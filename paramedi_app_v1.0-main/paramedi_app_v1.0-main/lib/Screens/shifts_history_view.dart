import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/shift_assignment_model.dart';
import '../core/models/shift_poll_model.dart';
import '../core/models/center_model.dart';
import '../core/providers/data_providers.dart';
import '../core/providers/service_providers.dart';
import '../core/providers/reservation_provider.dart';
import '../core/services/reservation_service.dart';


class ShiftsHistoryView extends ConsumerStatefulWidget {
  const ShiftsHistoryView({super.key});

  @override
  ConsumerState<ShiftsHistoryView> createState() => _ShiftsHistoryViewState();
}

class _ShiftsHistoryViewState extends ConsumerState<ShiftsHistoryView> {
  bool _submitting = false;
  int? _loadedForPlanId;
  int? _selectedCenterId;

  void _ensureReservationsLoaded(ShiftPollModel poll) {
    final planId = poll.planId;
    if (planId == null || _loadedForPlanId == planId) return;
    _loadedForPlanId = planId;

    final notifier = ref.read(reservationProvider(planId).notifier);
    final pusherClient = ref.read(wsProvider).client;
    // Fire-and-forget: load() fetches the REST snapshot then subscribes to
    // the shared websocket channel so other users' reservations appear live.
    notifier.load(pusherClient);
  }

  Future<void> _onTapShift(ShiftPollModel poll, int? centerId, ShiftSelection sel) async {
    final planId = poll.planId;
    if (planId == null) return;

    if (centerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No centers available to reserve yet.')),
        );
      }
      return;
    }

    final notifier = ref.read(reservationProvider(planId).notifier);

    final alreadyMine = notifier.isReservedByCurrentUser(centerId, sel.day, sel.shift, poll.role);
    try {
      if (alreadyMine) {
        await notifier.release(centerId, sel.day, sel.shift, poll.role);
      } else {
        await notifier.reserve(centerId, sel.day, sel.shift, poll.role);
      }
    } on ReservationConflictException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  Future<void> _submitPoll(ShiftPollModel poll) async {
    setState(() => _submitting = true);
    try {
      final planId = poll.planId;
      if (planId != null) {
        await ref.read(reservationProvider(planId).notifier).confirmAll();
      }
      await ref.read(shiftServiceProvider).submitPoll(
            poll.id,
            const [],
            const [],
          );
      ref.invalidate(currentPollProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pollState = ref.watch(currentPollProvider);
    final scheduleState = ref.watch(myScheduleProvider);
    final centersState = ref.watch(centersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Shift System',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentPollProvider);
          ref.invalidate(myScheduleProvider);
          ref.invalidate(centersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Current Poll',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            pollState.when(
              data: (poll) {
                if (poll == null) return const _EmptyPanel(text: 'No active poll');

                _ensureReservationsLoaded(poll);

                if (poll.planId == null) {
                  return const _EmptyPanel(text: 'Poll is missing its plan id');
                }

                // The poll must always be shown once it exists — the centers
                // list only affects the center dropdown inside the poll, it
                // must never hide the poll itself (empty/loading/error states
                // of centersState degrade the dropdown only, see _PollPanel).
                final centers = centersState.value ?? const [];
                if (centers.isNotEmpty) {
                  _selectedCenterId ??= centers.first.id;
                }

                // _PollPanel itself watches reservationProvider, so it
                // rebuilds on every websocket event
                // (ShiftReserved/Released/Confirmed) with no page refresh.
                return _PollPanel(
                  poll: poll,
                  centers: centers,
                  centersLoading: centersState.isLoading,
                  selectedCenterId: _selectedCenterId,
                  onCenterChanged: (id) => setState(() => _selectedCenterId = id),
                  submitting: _submitting,
                  onTapShift: (sel) => _onTapShift(poll, _selectedCenterId, sel),
                  onSubmit: () => _submitPoll(poll),
                );
              },
              loading: () => const _LoadingPanel(),
              error: (e, _) => _EmptyPanel(text: 'Poll error: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'My Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            scheduleState.when(
              data: (items) {
                final today = DateTime.now();
                final todayOnly = DateTime(today.year, today.month, today.day);
                final upcoming = items.where((item) {
                  final date = DateTime.tryParse(item.date);
                  return date == null || !date.isBefore(todayOnly);
                }).toList();

                return upcoming.isEmpty
                    ? const _EmptyPanel(text: 'No upcoming shifts')
                    : Column(
                        children: upcoming
                            .map((item) => _ScheduleCard(assignment: item))
                            .toList(),
                      );
              },
              loading: () => const _LoadingPanel(),
              error: (e, _) => _EmptyPanel(text: 'Schedule error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Poll Panel ──────────────────────────────────────────────────────────────

class _PollPanel extends ConsumerWidget {
  final ShiftPollModel poll;
  final List<CenterModel> centers;
  final bool centersLoading;
  final int? selectedCenterId;
  final ValueChanged<int> onCenterChanged;
  final bool submitting;
  final ValueChanged<ShiftSelection> onTapShift;
  final VoidCallback onSubmit;

  const _PollPanel({
    required this.poll,
    required this.centers,
    required this.centersLoading,
    required this.selectedCenterId,
    required this.onCenterChanged,
    required this.submitting,
    required this.onTapShift,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationProvider(poll.planId!));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll header
          Row(
            children: [
              const Icon(Icons.how_to_vote_outlined, color: Color(0xFFE52E2E)),
              const SizedBox(width: 8),
              Text(
                'Role: ${poll.role}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: poll.status == 'pending'
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: poll.status == 'pending'
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                  ),
                ),
                child: Text(
                  poll.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: poll.status == 'pending'
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Center selector — the user chooses the exact center they want to
          // work at; the reservation locks that center, not just the time.
          // The poll itself must always render even when the centers list is
          // empty/loading/erroring — only the dropdown degrades.
          const Text(
            'Center',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          if (centers.isNotEmpty)
            DropdownButtonFormField<int>(
              initialValue: selectedCenterId,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: centers
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (id) {
                if (id != null) onCenterChanged(id);
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      centersLoading ? 'Loading centers...' : 'No centers available.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFFE52E2E), label: 'Selected by you'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.grey.shade400, label: 'Reserved by another'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.green.shade400, label: 'Confirmed'),
            ],
          ),
          const SizedBox(height: 12),

          // Day cards. These must always render, even with no center selected
          // yet (e.g. centers list still empty) — only individual shift taps
          // are disabled in that case (see _DayCard/_ShiftSlotChip), never the
          // whole grid.
          _DayShiftPicker(
            centerId: selectedCenterId,
            role: poll.role,
            reservations: reservations,
            onTapShift: onTapShift,
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(submitting ? 'Submitting...' : 'Submit Poll'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52E2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend Dot ──────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ─── Day + Shift Picker ───────────────────────────────────────────────────────

class _DayShiftPicker extends StatelessWidget {
  final int? centerId;
  final String role;
  final ReservationNotifier reservations;
  final ValueChanged<ShiftSelection> onTapShift;

  const _DayShiftPicker({
    required this.centerId,
    required this.role,
    required this.reservations,
    required this.onTapShift,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(31, (index) {
        final day = index + 1;
        return _DayCard(
          centerId: centerId,
          day: day,
          role: role,
          reservations: reservations,
          onTapShift: onTapShift,
        );
      }),
    );
  }
}

// ─── Day Card (expandable) ────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  // Null when no center is selected yet (e.g. centers list is still empty) —
  // the day/shift grid must still render in that case, just with every slot
  // showing as available/untappable rather than reflecting real reservation
  // state, since no reservation can exist for "no center".
  final int? centerId;
  final int day;
  final String role;
  final ReservationNotifier reservations;
  final ValueChanged<ShiftSelection> onTapShift;

  static const _shiftTypes = ['morning', 'evening', 'night'];
  static const _shiftLabels = {
    'morning': 'Morning',
    'evening': 'Evening',
    'night': 'Night'
  };
  static const _shiftIcons = {
    'morning': Icons.wb_sunny_outlined,
    'evening': Icons.wb_twilight,
    'night': Icons.nights_stay_outlined,
  };

  const _DayCard({
    required this.centerId,
    required this.day,
    required this.role,
    required this.reservations,
    required this.onTapShift,
  });

  bool _hasAnySelection() {
    if (centerId == null) return false;
    return _shiftTypes.any((s) => reservations.isReserved(centerId!, day, s, role));
  }

  String _buildSummary() {
    if (centerId == null) return '';
    final parts = <String>[];
    for (final s in _shiftTypes) {
      if (reservations.isReservedByCurrentUser(centerId!, day, s, role)) {
        parts.add('${reservations.isConfirmed(centerId!, day, s, role) ? '✓' : '●'} ${_shiftLabels[s]}');
      } else if (reservations.isReserved(centerId!, day, s, role)) {
        parts.add('🔒 ${_shiftLabels[s]}');
      }
    }
    return parts.join('  ');
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _hasAnySelection();

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: hasSelection ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: hasSelection
              ? const Color(0xFFE52E2E).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: hasSelection
              ? const Color(0xFFE52E2E).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: hasSelection ? const Color(0xFFE52E2E) : Colors.grey.shade700,
            ),
          ),
        ),
        title: Text(
          'Day $day',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: hasSelection
            ? Text(
                _buildSummary(),
                style: const TextStyle(fontSize: 11, color: Color(0xFFE52E2E)),
              )
            : null,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 12),
              ..._shiftTypes.map((shiftType) {
                final sel = ShiftSelection(day: day, shift: shiftType);
                final mine = centerId != null &&
                    reservations.isReservedByCurrentUser(centerId!, day, shiftType, role);
                final lockedByOther = centerId != null &&
                    reservations.isReserved(centerId!, day, shiftType, role) &&
                    !mine;
                final confirmed = centerId != null &&
                    reservations.isConfirmed(centerId!, day, shiftType, role);
                return _ShiftRow(
                  icon: _shiftIcons[shiftType]!,
                  label: _shiftLabels[shiftType]!,
                  selectedByMe: mine,
                  lockedByOther: lockedByOther,
                  confirmed: confirmed,
                  // Tapping with no center selected is handled by
                  // _onTapShift (shows "select a center first"), not blocked
                  // here — the grid stays interactive-looking either way.
                  onTap: lockedByOther ? null : () => onTapShift(sel),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shift Row ────────────────────────────────────────────────────────────────

class _ShiftRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selectedByMe;
  final bool lockedByOther;
  final bool confirmed;
  final VoidCallback? onTap;

  const _ShiftRow({
    required this.icon,
    required this.label,
    required this.selectedByMe,
    required this.lockedByOther,
    required this.confirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const Spacer(),
          _ShiftSlotChip(
            selectedByMe: selectedByMe,
            lockedByOther: lockedByOther,
            confirmed: confirmed,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// ─── Shift Slot Chip ──────────────────────────────────────────────────────────
//
// Available -> normal color, tappable.
// Selected by current user -> red, tappable (tap again to release).
// Reserved by another user -> grey, lock icon, disabled.
// Confirmed -> locked green, disabled.

class _ShiftSlotChip extends StatelessWidget {
  final bool selectedByMe;
  final bool lockedByOther;
  final bool confirmed;
  final VoidCallback? onTap;

  const _ShiftSlotChip({
    required this.selectedByMe,
    required this.lockedByOther,
    required this.confirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    String label;
    IconData? icon;

    if (confirmed && selectedByMe) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      border = Colors.green.shade400;
      label = 'Confirmed';
      icon = Icons.check_circle;
    } else if (lockedByOther) {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade600;
      border = Colors.grey.shade400;
      label = 'Reserved';
      icon = Icons.lock;
    } else if (selectedByMe) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      border = Colors.red.shade600;
      label = 'Selected';
      icon = null;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
      border = Colors.grey.shade300;
      label = 'Available';
      icon = null;
    }

    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: selectedByMe ? 1.5 : 1.0),
        ),
        child: Opacity(
          opacity: disabled && !lockedByOther ? 0.6 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selectedByMe ? FontWeight.bold : FontWeight.normal,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Schedule Card ────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final ShiftAssignmentModel assignment;

  const _ScheduleCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Color(0xFFE52E2E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.date,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${assignment.shiftType} - ${assignment.center.isEmpty ? 'No center' : assignment.center}',
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                assignment.role,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: assignment.isDone ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: assignment.isDone ? Colors.green.shade300 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  assignment.isDone ? 'Attended' : 'Selected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: assignment.isDone ? Colors.green.shade700 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Loading / Empty Panels ───────────────────────────────────────────────────

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      alignment: Alignment.center,
      decoration: _panelDecoration(),
      child: const CircularProgressIndicator(),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;

  const _EmptyPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
