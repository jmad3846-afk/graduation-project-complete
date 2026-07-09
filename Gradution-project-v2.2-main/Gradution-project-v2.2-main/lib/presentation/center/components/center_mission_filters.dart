import 'package:flutter/material.dart';

class CenterMissionFilters extends StatefulWidget {
  const CenterMissionFilters({super.key});

  @override
  State<CenterMissionFilters> createState() => _CenterMissionFiltersState();
}

class _CenterMissionFiltersState extends State<CenterMissionFilters> {
  String? caseCode;
  String? caseType;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔍 مرشحات مهمات المركز',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _dropdown('كود الحالة', caseCode,
                ['أحمر', 'أصفر', 'أخضر', 'أسود'],
                    (v) => setState(() => caseCode = v)),
            const SizedBox(height: 12),
            _dropdown('نوع الحادث', caseType,
                ['حادث سير', 'قلب', 'أخرى'],
                    (v) => setState(() => caseType = v)),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              child: const Text('تطبيق الفلترة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
