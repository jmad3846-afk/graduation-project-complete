import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/shift_management_provider.dart';
import 'package:ems_op_room/core/models/schedule_row_model.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';

class ScheduleDistributionPage extends ConsumerStatefulWidget {
  final int? planId;

  const ScheduleDistributionPage({super.key, this.planId});

  @override
  ConsumerState<ScheduleDistributionPage> createState() =>
      _ScheduleDistributionPageState();
}

class _ScheduleDistributionPageState
    extends ConsumerState<ScheduleDistributionPage> {
  int? _resolvedPlanId;
  List<ScheduleRowModel> _rows = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    int? planId = widget.planId;

    if (planId == null) {
      final notifier = ref.read(shiftManagementProvider.notifier);
      await notifier.loadAll();
      final plans = ref.read(shiftManagementProvider).plans;
      final published = plans.where((p) => p.status == 'published').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      planId = published.isNotEmpty ? published.first.id : null;
    }

    if (planId == null) {
      setState(() {
        _loading = false;
        _error = 'لا توجد خطة منشورة لعرضها';
      });
      return;
    }

    final rows =
        await ref.read(shiftManagementProvider.notifier).fetchSchedule(planId);

    if (!mounted) return;
    setState(() {
      _resolvedPlanId = planId;
      _rows = rows;
      _loading = false;
    });
  }

  Future<void> _sendSchedule() async {
    final planId = _resolvedPlanId;
    if (planId == null) return;

    setState(() => _sending = true);
    final ok =
        await ref.read(shiftManagementProvider.notifier).sendSchedule(planId);
    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'تم إرسال الجدول للمسعفين' : 'فشل إرسال الجدول'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  String _assigneeLabel(ScheduleAssigneeModel? assignee) {
    if (assignee == null || assignee.name.isEmpty) return 'Empty';
    return assignee.name;
  }

  String _formatDay(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('توزيع الجدول')),
        body: _loading
            ? const AppLoadingIndicator(message: 'جاري تحميل الجدول...')
            : _error != null
                ? AppErrorWidget(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const AppSectionHeader(
                                  title: 'الجدول المنشور',
                                  subtitle:
                                      'جميع المراكز والأيام والمناوبات، بما فيها الفارغة',
                                ),
                                const SizedBox(height: 16),
                                _rows.isEmpty
                                    ? const AppEmptyState(
                                        message: 'لا توجد بيانات جدول لهذه الخطة')
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          columns: const [
                                            DataColumn(label: Text('المركز')),
                                            DataColumn(label: Text('اليوم')),
                                            DataColumn(label: Text('المناوبة')),
                                            DataColumn(label: Text('القائد')),
                                            DataColumn(label: Text('الكشاف')),
                                            DataColumn(label: Text('المسعف')),
                                          ],
                                          rows: _rows.map((row) {
                                            return DataRow(cells: [
                                              DataCell(Text(row.center)),
                                              DataCell(Text(_formatDay(row.date))),
                                              DataCell(Text(row.shiftType)),
                                              DataCell(
                                                  Text(_assigneeLabel(row.leader))),
                                              DataCell(
                                                  Text(_assigneeLabel(row.scout))),
                                              DataCell(Text(
                                                  _assigneeLabel(row.paramedic))),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _sending || _resolvedPlanId == null ? null : _sendSchedule,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.send),
                              label: const Text('إرسال الجدول'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
