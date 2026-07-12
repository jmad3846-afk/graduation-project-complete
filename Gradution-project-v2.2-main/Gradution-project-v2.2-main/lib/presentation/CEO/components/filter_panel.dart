// ignore_for_file: deprecated_member_use

import 'package:ems_op_room/core/app_colors.dart';
import 'package:ems_op_room/core/widgets/animation_widgets.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key});

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  String? selectedSector;
  String? selectedCaseCode;
  String? selectedCaseType;
  DateTime? selectedDate;

  final Map<String, int> statusMissionCounts = {
    'أحمر (خطر)': 5,
    'أصفر (متوسط)': 12,
    'أسود (لم يتم النقل)': 3,
    'الكل': 20,
  };

  final List<String> sectors = const ['140', '100', '110', '115'];
  final List<String> caseCodes = const [
    'أحمر (خطر)',
    'أصفر (متوسط)',
    'أسود (لم يتم النقل)',
    'الكل',
  ];
  final List<String> caseTypes = const [
    'حادث سير',
    'حريق',
    'كسر',
    'أمراض قلبية',
    'أمراض عصبية',
    'أمراض هضمية',
    'آخر',
  ];

  Color _getColor(String status) {
    if (status.contains('أحمر')) return AppColors.statusRed;
    if (status.contains('أصفر')) return AppColors.statusYellow;
    if (status.contains('أسود')) return Colors.black87;
    return AppColors.statusGrey;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'اختر تاريخ المهمة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      selectedSector = null;
      selectedCaseCode = null;
      selectedCaseType = null;
      selectedDate = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeFilters =
        [
          selectedSector,
          selectedCaseCode,
          selectedCaseType,
          selectedDate != null ? _formatDate(selectedDate) : null,
        ].whereType<String>().length;

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فلترة الحالات',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        'خصص العرض حسب القطاع، الأولوية، النوع والتاريخ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.75,
                          ),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                if (activeFilters > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$activeFilters مفعّل',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  statusMissionCounts.entries.map((entry) {
                    return FadeInAnimation(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _getColor(entry.key).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getColor(entry.key).withOpacity(0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge(
                              label: entry.key,
                              color: _getColor(entry.key),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 18),
            _buildSectionLabel(context, 'معايير الفلترة'),
            const SizedBox(height: 12),
            FadeInAnimation(
              child: _buildDropdownFilter(
                label: 'القطاع',
                value: selectedSector,
                items: sectors,
                onChanged:
                    (String? newValue) =>
                        setState(() => selectedSector = newValue),
                icon: Icons.location_city_rounded,
              ),
            ),
            const SizedBox(height: 12),
            FadeInAnimation(
              child: _buildDropdownFilter(
                label: 'كود الحالة',
                value: selectedCaseCode,
                items: caseCodes,
                onChanged:
                    (String? newValue) =>
                        setState(() => selectedCaseCode = newValue),
                icon: Icons.priority_high_rounded,
              ),
            ),
            const SizedBox(height: 12),
            FadeInAnimation(
              child: _buildDropdownFilter(
                label: 'نوع الحادث',
                value: selectedCaseType,
                items: caseTypes,
                onChanged:
                    (String? newValue) =>
                        setState(() => selectedCaseType = newValue),
                icon: Icons.medical_services_rounded,
              ),
            ),
            const SizedBox(height: 12),
            FadeInAnimation(
              child: _DateFilterField(
                label: 'التاريخ',
                value: _formatDate(selectedDate),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(context, 'ملخص الفلاتر'),
            const SizedBox(height: 10),
            if (activeFilters == 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.10),
                  ),
                ),
                child: Text(
                  'لم يتم تحديد أي فلتر بعد. سيتم عرض جميع الحالات والمهام.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (selectedSector != null)
                    _FilterChipView(
                      label: 'القطاع: $selectedSector',
                      onDeleted: () => setState(() => selectedSector = null),
                    ),
                  if (selectedCaseCode != null)
                    _FilterChipView(
                      label: 'الأولوية: $selectedCaseCode',
                      onDeleted: () => setState(() => selectedCaseCode = null),
                    ),
                  if (selectedCaseType != null)
                    _FilterChipView(
                      label: 'النوع: $selectedCaseType',
                      onDeleted: () => setState(() => selectedCaseType = null),
                    ),
                  if (selectedDate != null)
                    _FilterChipView(
                      label: 'التاريخ: ${_formatDate(selectedDate)}',
                      onDeleted: () => setState(() => selectedDate = null),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('إعادة ضبط'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تطبيق الفلتر بنجاح')),
                      );
                    },
                    icon: const Icon(Icons.filter_alt_rounded),
                    label: const Text('تطبيق الفلتر'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title,
      textDirection: TextDirection.rtl,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            hintText: 'اختر $label',
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          items:
              items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    textDirection: TextDirection.rtl,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DateFilterField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          value == 'اختر التاريخ'
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                0.6,
                              )
                              : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipView extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChipView({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label, textDirection: TextDirection.rtl),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close_rounded, size: 18),
    );
  }
}
