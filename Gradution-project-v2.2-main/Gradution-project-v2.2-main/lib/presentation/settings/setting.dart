// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  Widget _buildLanguageOption(
    BuildContext context,
    AppLanguage optionLanguage,
    AppLanguage currentLanguage,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentLanguage == optionLanguage;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(languageProvider.notifier).setLanguage(optionLanguage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tr('languageUpdated')),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                optionLanguage.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                optionLanguage.code.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);
    final l10n = AppLocalizations(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr('settings'),
          style: TextStyle(color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: isDarkMode ? Colors.amber.shade700 : Colors.blueGrey,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      l10n.tr('darkMode'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setTheme(value);
                  },
                  activeThumbColor: theme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('language'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tr('languageDescription'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLanguageOption(
                      context,
                      AppLanguage.english,
                      language,
                      ref,
                      l10n,
                    ),
                    _buildLanguageOption(
                      context,
                      AppLanguage.arabic,
                      language,
                      ref,
                      l10n,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text(l10n.tr('notificationsSettings')),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.hintColor,
            ),
          ),
          ListTile(
            title: Text(l10n.tr('logout')),
            trailing: Icon(
              Icons.exit_to_app,
              size: 16,
              color: theme.primaryColor,
            ),
            onTap: () {
              // Logout logic
            },
          ),
        ],
      ),
    );
  }
}