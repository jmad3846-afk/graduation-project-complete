// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:ems_op_room/core/services/data_service.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';

class EnhancedSettingsPage extends ConsumerWidget {
  const EnhancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);
    final l10n = AppLocalizations(language);
    final dataService = DataService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('settings')),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSettingsCard(
            context,
            l10n.tr('language'),
            l10n.tr('languageDescription'),
            [
              _buildLanguageOption(
                context,
                AppLanguage.english,
                language,
                ref,
                dataService,
                l10n,
              ),
              _buildLanguageOption(
                context,
                AppLanguage.arabic,
                language,
                ref,
                dataService,
                l10n,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Theme Section
          _buildSettingsCard(
            context,
            l10n.tr('darkMode'),
            l10n.tr('displayModeHint'),
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? Colors.amber.shade700 : Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDarkMode ? l10n.tr('darkMode') : l10n.tr('lightMode'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) async {
                      ref.read(themeProvider.notifier).setTheme(value);
                      await dataService.saveTheme(value);
                    },
                    activeThumbColor: theme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Management Section
          _buildSettingsCard(
            context,
            'إدارة البيانات',
            'إدارة بيانات التطبيق والنسخ الاحتياطي',
            [
              _buildDataAction(
                context,
                'إعادة تعيين البيانات',
                Icons.refresh,
                Colors.red,
                () async {
                  await dataService.resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إعادة تعيين البيانات إلى الإعدادات الافتراضية'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildDataAction(
                context,
                'مسح جميع البيانات',
                Icons.delete_forever,
                Colors.red,
                () async {
                  await dataService.clearAllData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم مسح جميع البيانات'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About Section
          _buildSettingsCard(
            context,
            'عن التطبيق',
            'معلومات حول نظام إدارة غرفة عمليات الإسعاف',
            [
              _buildAboutItem(context, 'الإصدار', '1.0.0'),
              _buildAboutItem(context, 'المطور', 'فريق التطوير'),
              _buildAboutItem(context, 'النظام', 'EMS Op Room'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return AppCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppLanguage optionLanguage,
    AppLanguage currentLanguage,
    WidgetRef ref,
    DataService dataService,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentLanguage == optionLanguage;

    return InkWell(
      onTap: () async {
        ref.read(languageProvider.notifier).setLanguage(optionLanguage);
        await dataService.saveLanguage(optionLanguage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tr('languageUpdated')),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  optionLanguage == AppLanguage.english 
                    ? Icons.language 
                    : Icons.translate,
                  color: isSelected ? theme.primaryColor : theme.hintColor,
                ),
                const SizedBox(width: 12),
                Text(
                  optionLanguage.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}