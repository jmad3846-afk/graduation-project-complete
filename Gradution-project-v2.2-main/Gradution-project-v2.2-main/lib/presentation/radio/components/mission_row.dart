// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'details_column.dart';
import 'editable_detail_column.dart';
import 'selectable_detail_column.dart';
import 'time_input_column.dart';

class MissionRow extends StatelessWidget {
  final Map<String, dynamic> mission;
  final Function(String missionId, String key, String value) onUpdate;
  final VoidCallback? onFinish;
  final bool isFinishing;

  const MissionRow({
    super.key,
    required this.mission,
    required this.onUpdate,
    this.onFinish,
    this.isFinishing = false,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Red':
        return Colors.red;
      case 'Yellow':
        return Colors.amber;
      case 'Green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
        Colors.grey;

    final status = mission['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    final header = Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mission['name'] ?? '',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: isFinishing ? null : onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: isFinishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'إنهاء',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );

    final List<Widget> details = [
      DetailsColumn(
        label: 'حالة المهمة',
        value: status,
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
        valueColor: statusColor,
        width: 100,
      ),
      DetailsColumn(
        label: 'مركز الاستجابة',
        value: mission['center'] ?? '',
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
        width: 100,
      ),
      EditableDetailColumn(
        label: 'رمز الإسعاف',
        keyName: 'code',
        initialValue: mission['code'] ?? '',
        missionId: mission['id'] ?? '',
        onUpdate: onUpdate,
        width: 100,
      ),
      EditableDetailColumn(
        label: 'قائد الفريق',
        keyName: 'teamLeader',
        initialValue: mission['teamLeader'] ?? '',
        missionId: mission['id'] ?? '',
        onUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'انطلاق (مريض)',
        timeKey: 'toPatientTime',
        initialValue: mission['toPatientTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'وصول (مريض)',
        timeKey: 'atPatientTime',
        initialValue: mission['atPatientTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'انطلاق (مشفى)',
        timeKey: 'toHospitalTime',
        initialValue: mission['toHospitalTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'وصول (مشفى)',
        timeKey: 'atHospitalTime',
        initialValue: mission['atHospitalTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'انطلاق (مركز)',
        timeKey: 'toCenterTime',
        initialValue: mission['toCenterTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      TimeInputColumn(
        label: 'وصول (مركز)',
        timeKey: 'atCenterTime',
        initialValue: mission['atCenterTime'] ?? '',
        missionId: mission['id'] ?? '',
        onTimeUpdate: onUpdate,
        width: 110,
      ),
      SelectableDetailColumn(
        label: 'حالة النقل',
        keyName: 'transferStatus',
        initialValue: mission['transferStatus'] ?? '',
        missionId: mission['id'] ?? '',
        onUpdate: onUpdate,
        options: const ['تم النقل', 'لم يتم النقل'],
        width: 120,
      ),
      (mission['transferStatus'] ?? '') == 'لم يتم النقل'
          ? EditableDetailColumn(
        label: 'سبب عدم النقل',
        keyName: 'reasonForNoTransfer',
        initialValue: mission['reasonForNoTransfer'] ?? '',
        missionId: mission['id'] ?? '',
        onUpdate: onUpdate,
        width: 200,
      )
          : EditableDetailColumn(
        label: 'المشفى',
        keyName: 'hospital',
        initialValue: mission['hospital'] ?? '',
        missionId: mission['id'] ?? '',
        onUpdate: onUpdate,
        width: 120,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 25, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          header,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1300) {
                return Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: details,
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details,
              );
            },
          ),
          Divider(color: secondaryTextColor.withOpacity(0.3)),
        ],
      ),
    );
  }
}
