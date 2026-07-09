import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/shift_management_provider.dart';
import 'package:ems_op_room/core/models/shift_plan_model.dart';
import 'package:ems_op_room/core/models/swap_request_model.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';

class ShiftManagementPage extends ConsumerStatefulWidget {
  const ShiftManagementPage({super.key});

  @override
  ConsumerState<ShiftManagementPage> createState() => _ShiftManagementPageState();
}

class _ShiftManagementPageState extends ConsumerState<ShiftManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(shiftManagementProvider.notifier).loadAll());
  }

  void _showCreatePlanDialog() async {
    final months = const [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;
    final List<int> years = List.generate(5, (index) => DateTime.now().year + index);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('إنشاء خطة مناوبات جديدة'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(months[m - 1]),
                      )).toList(),
                      onChanged: (v) => setState(() => selectedMonth = v ?? selectedMonth),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: years.map((y) => DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      )).toList(),
                      onChanged: (v) => setState(() => selectedYear = v ?? selectedYear),
                    ),
                  ],
                );
              }
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('إنشاء'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      ref.read(shiftManagementProvider.notifier).createPlan(selectedMonth, selectedYear);
    }
  }

  Widget _buildStatusBadge(String status) {
    String label = '';
    Color color = Colors.grey;

    switch (status) {
      case 'draft':
        label = 'مسودة';
        color = Colors.blueGrey;
        break;
      case 'polling_leaders':
        label = 'استطلاع القادة';
        color = Colors.orange;
        break;
      case 'polling_scouts':
        label = 'استطلاع الكشافة';
        color = Colors.orangeAccent;
        break;
      case 'polling_paramedics':
        label = 'استطلاع المسعفين';
        color = Colors.deepOrange;
        break;
      case 'building':
        label = 'جاري البناء';
        color = Colors.purple;
        break;
      case 'published':
        label = 'منشور';
        color = Colors.green;
        break;
      case 'closed':
        label = 'مغلق';
        color = Colors.red;
        break;
      default:
        label = status;
        color = Colors.grey;
    }

    return StatusBadge(label: label, color: color);
  }

  Widget _buildStatistics(ShiftManagementState state) {
    int totalPlans = state.plans.length;
    int publishedPlans = state.plans.where((p) => p.status == 'published').length;
    int pendingPolls = state.statistics.totalPolls - state.statistics.submittedPolls;
    if (pendingPolls < 0) pendingPolls = 0;
    int completedPolls = state.statistics.submittedPolls;
    int pendingSwap = state.swapRequests.where((r) => r.status == 'pending').length;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 6 : MediaQuery.of(context).size.width > 800 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AppMetricChip(label: 'إجمالي الخطط', value: totalPlans.toString(), icon: Icons.calendar_today, color: Colors.blue),
        AppMetricChip(label: 'الخطط المنشورة', value: publishedPlans.toString(), icon: Icons.check_circle, color: Colors.green),
        AppMetricChip(label: 'الاستطلاعات المعلقة', value: pendingPolls.toString(), icon: Icons.pending_actions, color: Colors.orange),
        AppMetricChip(label: 'الاستطلاعات المكتملة', value: completedPolls.toString(), icon: Icons.how_to_vote, color: Colors.teal),
        AppMetricChip(label: 'إجمالي التعيينات', value: state.statistics.totalAssignments.toString(), icon: Icons.assignment_ind, color: Colors.indigo),
        AppMetricChip(label: 'طلبات التبديل المعلقة', value: pendingSwap.toString(), icon: Icons.swap_horiz, color: Colors.deepOrange),
      ],
    );
  }

  Widget _buildPlansTable(List<ShiftPlanModel> plans) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(
            title: 'خطط المناوبات',
            subtitle: 'إدارة خطط المناوبات الشهرية والاستطلاعات',
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('رقم الخطة')),
                DataColumn(label: Text('الشهر')),
                DataColumn(label: Text('السنة')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('تاريخ الإنشاء')),
                DataColumn(label: Text('الإجراءات')),
              ],
              rows: plans.map((plan) {
                final date = '${plan.createdAt.year}-${plan.createdAt.month.toString().padLeft(2, '0')}-${plan.createdAt.day.toString().padLeft(2, '0')}';
                return DataRow(
                  cells: [
                    DataCell(Text('#${plan.id}')),
                    DataCell(Text(plan.month.toString())),
                    DataCell(Text(plan.year.toString())),
                    DataCell(_buildStatusBadge(plan.status)),
                    DataCell(Text(date)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (plan.status == 'draft')
                          IconButton(
                            tooltip: 'بدء استطلاع القادة',
                            icon: const Icon(Icons.record_voice_over, color: Colors.orange),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).startLeaderPoll(plan.id),
                          ),
                        if (plan.status == 'polling_leaders')
                          IconButton(
                            tooltip: 'بدء استطلاع الكشافة',
                            icon: const Icon(Icons.groups, color: Colors.orange),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).startScoutPoll(plan.id),
                          ),
                        if (plan.status == 'polling_scouts')
                          IconButton(
                            tooltip: 'بدء استطلاع المسعفين',
                            icon: const Icon(Icons.local_hospital, color: Colors.orange),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).startParamedicPoll(plan.id),
                          ),
                        if (plan.status == 'polling_paramedics')
                          IconButton(
                            tooltip: 'بناء الجدول',
                            icon: const Icon(Icons.build_circle, color: Colors.purple),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).buildPlan(plan.id),
                          ),
                        if (plan.status == 'building')
                          IconButton(
                            tooltip: 'نشر الجدول',
                            icon: const Icon(Icons.publish, color: Colors.green),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).publishPlan(plan.id),
                          ),
                        if (plan.status == 'published')
                          IconButton(
                            tooltip: 'إغلاق الخطة',
                            icon: const Icon(Icons.lock, color: Colors.red),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).closePlan(plan.id),
                          ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapRequestsTable(List<SwapRequestModel> requests) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(
            title: 'طلبات التبديل',
            subtitle: 'إدارة طلبات تبديل المناوبات بين الموظفين',
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('المرسل')),
                DataColumn(label: Text('المستهدف')),
                DataColumn(label: Text('الدور')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('تاريخ الإنشاء')),
                DataColumn(label: Text('الإجراءات')),
              ],
              rows: requests.map((req) {
                final date = req.createdAt != null 
                    ? '${req.createdAt!.year}-${req.createdAt!.month.toString().padLeft(2, '0')}-${req.createdAt!.day.toString().padLeft(2, '0')}'
                    : '-';
                String statusLabel = req.status;
                Color statusColor = Colors.grey;
                if (req.status == 'pending') {
                  statusLabel = 'قيد الانتظار';
                  statusColor = Colors.orange;
                } else if (req.status == 'approved') {
                  statusLabel = 'معتمد';
                  statusColor = Colors.green;
                } else if (req.status == 'rejected') {
                  statusLabel = 'مرفوض';
                  statusColor = Colors.red;
                } else if (req.status == 'accepted_by_target') {
                  statusLabel = 'مقبول من المستهدف';
                  statusColor = Colors.blue;
                }

                return DataRow(
                  cells: [
                    DataCell(Text('#${req.id}')),
                    DataCell(Text(req.requesterName)),
                    DataCell(Text(req.targetName)),
                    DataCell(Text(req.role)),
                    DataCell(StatusBadge(label: statusLabel, color: statusColor)),
                    DataCell(Text(date)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (req.status == 'pending' || req.status == 'accepted_by_target') ...[
                          IconButton(
                            tooltip: 'اعتماد',
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).approveSwap(req.id),
                          ),
                          IconButton(
                            tooltip: 'رفض',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => ref.read(shiftManagementProvider.notifier).rejectSwap(req.id),
                          ),
                        ] else ...[
                          const Text('-')
                        ]
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftManagementProvider);

    ref.listen<ShiftManagementState>(shiftManagementProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.red,
        ));
        ref.read(shiftManagementProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: Colors.green,
        ));
        ref.read(shiftManagementProvider.notifier).clearMessages();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المناوبات'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreatePlanDialog,
          icon: const Icon(Icons.add),
          label: const Text('إنشاء خطة جديدة'),
        ),
        body: state.isLoading && state.plans.isEmpty
            ? const AppLoadingIndicator(message: 'جاري تحميل البيانات...')
            : RefreshIndicator(
                onRefresh: () => ref.read(shiftManagementProvider.notifier).loadAll(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppSectionHeader(
                        title: 'الإحصائيات',
                        subtitle: 'نظرة عامة على حالة المناوبات والاستطلاعات',
                      ),
                      const SizedBox(height: 16),
                      _buildStatistics(state),
                      const SizedBox(height: 32),
                      _buildPlansTable(state.plans),
                      const SizedBox(height: 32),
                      _buildSwapRequestsTable(state.swapRequests),
                      const SizedBox(height: 60), // padding for FAB
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
