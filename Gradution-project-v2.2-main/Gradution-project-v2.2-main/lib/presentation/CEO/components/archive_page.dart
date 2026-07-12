import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/archive_provider.dart';
import 'package:ems_op_room/core/models/archive_model.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archiveProvider.notifier).loadAll());
  }

  Color _triageColor(String? code) {
    switch (code) {
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.amber;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  Widget _buildTable(List<ArchiveModel> archives, bool isBusy) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(
            title: 'الحالات المؤرشفة',
            subtitle: 'سجل الحالات المغلقة والمؤرشفة',
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('رقم الحالة')),
                DataColumn(label: Text('المريض')),
                DataColumn(label: Text('المركز')),
                DataColumn(label: Text('رمز الترياج')),
                DataColumn(label: Text('تاريخ الأرشفة')),
                DataColumn(label: Text('حالة الطباعة')),
                DataColumn(label: Text('الإجراءات')),
              ],
              rows: archives.map((archive) {
                return DataRow(
                  cells: [
                    DataCell(Text('#${archive.caseId}')),
                    DataCell(Text(archive.patientName ?? '-')),
                    DataCell(Text(archive.centerName ?? '-')),
                    DataCell(
                      archive.triageCode != null
                          ? StatusBadge(label: archive.triageCode!, color: _triageColor(archive.triageCode))
                          : const Text('-'),
                    ),
                    DataCell(Text(_formatDate(archive.archivedAt))),
                    DataCell(
                      StatusBadge(
                        label: archive.printed ? 'تمت الطباعة' : 'لم تتم الطباعة',
                        color: archive.printed ? Colors.green : Colors.orange,
                      ),
                    ),
                    DataCell(
                      archive.printed
                          ? const Text('-')
                          : IconButton(
                              tooltip: 'تحديد كمطبوعة',
                              icon: const Icon(Icons.print, color: Colors.blue),
                              onPressed: isBusy
                                  ? null
                                  : () => ref.read(archiveProvider.notifier).markPrinted(archive.id),
                            ),
                    ),
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
    final state = ref.watch(archiveProvider);

    ref.listen<ArchiveState>(archiveProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.red,
        ));
        ref.read(archiveProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: Colors.green,
        ));
        ref.read(archiveProvider.notifier).clearMessages();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأرشيف')),
        body: state.isLoading && state.archives.isEmpty
            ? const AppLoadingIndicator(message: 'جاري تحميل الأرشيف...')
            : RefreshIndicator(
                onRefresh: () => ref.read(archiveProvider.notifier).loadAll(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: state.archives.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('لا توجد حالات مؤرشفة')),
                        )
                      : _buildTable(state.archives, state.isLoading),
                ),
              ),
      ),
    );
  }
}
