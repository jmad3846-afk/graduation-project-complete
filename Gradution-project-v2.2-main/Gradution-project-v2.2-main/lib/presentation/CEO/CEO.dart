// ----------------------------------------------------
// ملف Flutter متكامل: لوحة التحكم مع التنقل بالمسارات
// ----------------------------------------------------

// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:ems_op_room/presentation/CEO/components/dashbord_body.dart';

// ------------------------------------------
// شاشة Overview Dashboard الرئيسية - محسنة
// ------------------------------------------

class OverviewDashboardScreen extends ConsumerWidget {
  const OverviewDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final l10n = AppLocalizations(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Directionality(
        textDirection: l10n.textDirection,
        child: DashboardBody(),
      ),
    );
  }
}
