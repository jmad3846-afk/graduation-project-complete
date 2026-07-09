import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _requesterController = TextEditingController();
  final _targetController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _requesterController.dispose();
    _targetController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(shiftServiceProvider).createSwapRequest(
            requesterAssignmentId: int.parse(_requesterController.text),
            targetAssignmentId: int.parse(_targetController.text),
            reason: _reasonController.text,
          );
      _requesterController.clear();
      _targetController.clear();
      _reasonController.clear();
      ref.invalidate(shiftRequestListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift request submitted')),
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
    final requestState = ref.watch(shiftRequestListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shift Requests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(shiftRequestListProvider),
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
                    _NumberField(
                      controller: _requesterController,
                      label: 'My assignment ID',
                    ),
                    const SizedBox(height: 10),
                    _NumberField(
                      controller: _targetController,
                      label: 'Target assignment ID',
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
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52E2E), foregroundColor: Colors.white),
                        child: Text(_submitting ? 'Submitting...' : 'Submit Request'),
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

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NumberField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
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
          Text('Assignments: ${request.requesterAssignmentId ?? '-'} / ${request.targetAssignmentId ?? '-'}'),
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
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
  );
}
