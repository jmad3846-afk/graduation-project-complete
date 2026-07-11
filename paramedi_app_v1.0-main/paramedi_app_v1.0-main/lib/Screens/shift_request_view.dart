import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/shift_assignment_model.dart';
import '../core/models/shift_request_model.dart';
import '../core/providers/data_providers.dart';
import '../core/providers/service_providers.dart';

class ShiftRequestView extends ConsumerStatefulWidget {
  const ShiftRequestView({super.key});

  @override
  ConsumerState<ShiftRequestView> createState() => _ShiftRequestViewState();
}

class _ShiftRequestViewState extends ConsumerState<ShiftRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  ShiftAssignmentModel? _mySelectedAssignment;
  SwapCandidateModel? _selectedCandidate;

  List<SwapCandidateModel> _candidates = [];
  bool _loadingCandidates = false;
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _onMyAssignmentChanged(ShiftAssignmentModel? assignment) async {
    setState(() {
      _mySelectedAssignment = assignment;
      _selectedCandidate = null;
      _candidates = [];
    });

    if (assignment == null) return;

    setState(() => _loadingCandidates = true);
    final candidates = await ref.read(shiftServiceProvider).fetchSwapCandidates(assignment.id);
    if (!mounted) return;
    setState(() {
      _candidates = candidates;
      _loadingCandidates = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mySelectedAssignment == null || _selectedCandidate == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(shiftServiceProvider).createSwapRequest(
            requesterAssignmentId: _mySelectedAssignment!.id,
            targetAssignmentId: _selectedCandidate!.id,
            reason: _reasonController.text,
          );
      setState(() {
        _mySelectedAssignment = null;
        _selectedCandidate = null;
        _candidates = [];
      });
      _reasonController.clear();
      ref.invalidate(shiftRequestListProvider);
      ref.invalidate(myScheduleProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift swap request submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(shiftRequestListProvider);
    final myScheduleState = ref.watch(myScheduleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shift Requests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shiftRequestListProvider);
          ref.invalidate(myScheduleProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _panelDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Swap Request', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    myScheduleState.when(
                      data: (assignments) => _MyShiftsDropdown(
                        assignments: assignments,
                        selected: _mySelectedAssignment,
                        onChanged: _onMyAssignmentChanged,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Failed to load your shifts: $e'),
                    ),
                    const SizedBox(height: 10),
                    if (_mySelectedAssignment != null)
                      _loadingCandidates
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            )
                          : _SwapWithDropdown(
                              candidates: _candidates,
                              selected: _selectedCandidate,
                              onChanged: (c) => setState(() => _selectedCandidate = c),
                            ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_submitting || _mySelectedAssignment == null || _selectedCandidate == null)
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52E2E), foregroundColor: Colors.white),
                        child: Text(_submitting ? 'Submitting...' : 'Send Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('My Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            requestState.when(
              data: (requests) => requests.isEmpty
                  ? const _EmptyPanel(text: 'No shift requests')
                  : Column(children: requests.map((request) => _RequestCard(request: request)).toList()),
              loading: () => const _LoadingPanel(),
              error: (e, _) => _EmptyPanel(text: 'Requests error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyShiftsDropdown extends StatelessWidget {
  final List<ShiftAssignmentModel> assignments;
  final ShiftAssignmentModel? selected;
  final ValueChanged<ShiftAssignmentModel?> onChanged;

  const _MyShiftsDropdown({
    required this.assignments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShiftAssignmentModel>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'My Shifts',
        border: OutlineInputBorder(),
      ),
      items: assignments
          .map((a) => DropdownMenuItem(
                value: a,
                child: Text('${a.date} • ${a.center} • ${a.shiftType} • ${a.role}', overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      validator: (value) => value == null ? 'Select one of your shifts' : null,
      onChanged: onChanged,
    );
  }
}

class _SwapWithDropdown extends StatelessWidget {
  final List<SwapCandidateModel> candidates;
  final SwapCandidateModel? selected;
  final ValueChanged<SwapCandidateModel?> onChanged;

  const _SwapWithDropdown({
    required this.candidates,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const Text('No matching users found to swap with', style: TextStyle(color: Colors.grey));
    }
    return DropdownButtonFormField<SwapCandidateModel>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Swap With',
        border: OutlineInputBorder(),
      ),
      items: candidates
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text('${c.userName} • ${c.date} • ${c.center} • ${c.shiftType}', overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      validator: (value) => value == null ? 'Select a user to swap with' : null,
      onChanged: onChanged,
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ShiftRequestModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.requesterName} -> ${request.targetName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _StatusPill(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Role: ${request.role}'),
          if (request.reason != null && request.reason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(request.reason!, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status == 'approved' ? const Color(0xFFE6F4EA) : const Color(0xFFFFF2CC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

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
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
  );
}
