import 'package:flutter/material.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';

class WelcomeButtonModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  WelcomeButtonModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  // Factory method to create localized buttons
  static List<WelcomeButtonModel> createLocalizedButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return [
      WelcomeButtonModel(
        title: l10n.tr('dashboard'),
        subtitle: l10n.tr('overview'),
        icon: Icons.dashboard,
        onTap: () {
          // Navigate to dashboard
        },
      ),
      WelcomeButtonModel(
        title: l10n.tr('settings'),
        subtitle: l10n.tr('languageDescription'),
        icon: Icons.settings,
        onTap: () {
          // Navigate to settings
        },
      ),
    ];
  }
}
