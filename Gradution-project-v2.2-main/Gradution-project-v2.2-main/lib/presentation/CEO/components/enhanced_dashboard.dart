// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:ems_op_room/core/widgets/performance_widgets.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';
import 'package:ems_op_room/presentation/CEO/components/active_missions.dart';
import 'package:ems_op_room/presentation/CEO/components/shift_state_card.dart';
import 'package:ems_op_room/presentation/CEO/components/map_placeholder.dart';

class EnhancedDashboard extends ConsumerWidget {
  final bool isMobile;
  const EnhancedDashboard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(languageProvider);

    return Directionality(
      textDirection: l10n.textDirection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Quick Actions
          _buildDashboardHeader(context, theme, l10n),
          
          const SizedBox(height: 16),

          // Key Metrics Cards
          _buildMetricsSection(context, theme, l10n),
          
          const SizedBox(height: 16),

          // Main Content Grid
          Expanded(
            child: isMobile 
              ? _buildMobileLayout(context, theme, l10n)
              : _buildDesktopLayout(context, theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return AppCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('dashboard'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tr('overview'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Emergency Alert Button
              IconButton(
                icon: const Icon(Icons.sos),
                color: Colors.red,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.tr('liveUpdate')),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                tooltip: 'Emergency Alert',
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data refreshed'),
                    ),
                  );
                },
                tooltip: 'Refresh Data',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return AppCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('liveOperationsSummary'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                context,
                l10n.tr('activeMissions'),
                '12',
                Icons.local_fire_department_rounded,
                Colors.redAccent,
              ),
              _buildMetricCard(
                context,
                l10n.tr('fieldTeams'),
                '45',
                Icons.groups_rounded,
                Colors.blueAccent,
              ),
              _buildMetricCard(
                context,
                l10n.tr('availableTeams'),
                '23',
                Icons.check_circle_rounded,
                Colors.green,
              ),
              _buildMetricCard(
                context,
                l10n.tr('ongoingAlerts'),
                '8',
                Icons.notifications_active_rounded,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Active Missions
          ActiveMissionsCard(
            activeMissions: const [
              {'id': '0555', 'type': 'حادث مروري', 'location': 'طريق المطار 102'},
              {'id': '0554', 'type': 'شك اشتباه', 'location': 'الرقة شارع دمشق'},
            ],
          ),
          const SizedBox(height: 16),
          
          // Map
          const MapPlaceholder(),
          const SizedBox(height: 16),
          
          // Center Status
          _buildCenterStatusSection(context, theme, l10n),
          const SizedBox(height: 16),
          
          // Shift Stats
          const ShiftStatsCard(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        // Left Column: Active Missions
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ActiveMissionsCard(
                activeMissions: const [
                  {'id': '0555', 'type': 'حادث مروري', 'location': 'طريق المطار 102'},
                  {'id': '0554', 'type': 'شك اشتباه', 'location': 'الرقة شارع دمشق'},
                ],
              ),
              const SizedBox(height: 16),
              const ShiftStatsCard(),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right Column: Map and Center Status
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const MapPlaceholder(),
              const SizedBox(height: 16),
              _buildCenterStatusSection(context, theme, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterStatusSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return AppCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة المراكز',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          OptimizedGridView<Map<String, dynamic>>(
            items: const [
              {'name': 'Center 100', 'activeTasks': 3, 'teams': {'active': 12, 'busy': 8, 'available': 15}},
              {'name': 'Center 115', 'activeTasks': 1, 'teams': {'active': 15, 'busy': 11, 'available': 13}},
            ],
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            shrinkWrap: true,
            itemBuilder: (context, center, index) {
              return CenterStatusCard(center: center);
            },
          ),
        ],
      ),
    );
  }
}