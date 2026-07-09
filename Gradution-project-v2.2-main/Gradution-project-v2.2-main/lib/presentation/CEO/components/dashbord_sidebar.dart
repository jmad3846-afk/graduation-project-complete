// ignore_for_file: deprecated_member_use

import 'package:ems_op_room/core/navigation/app_router.dart';
import 'package:ems_op_room/core/providers/app_providers.dart';
import 'package:ems_op_room/core/widgets/animation_widgets.dart';
import 'package:ems_op_room/core/widgets/performance_widgets.dart';
import 'package:ems_op_room/core/widgets/shared_widgets.dart';
import 'package:ems_op_room/presentation/CEO/ambulance_distribution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ems_op_room/core/providers/auth_provider.dart';

class DashboardSidebar extends ConsumerWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);
    final bool isCompact = MediaQuery.of(context).size.width < 1100;

    final List<Map<String, dynamic>> navItems = [
      {
        'name': 'نظرة عامة',
        'subtitle': 'ملخص الأداء اللحظي',
        'icon': Icons.space_dashboard_rounded,
        'route': AppRouteKeys.overview,
        'notificationCount': null,
      },
      {
        'name': 'قائمة البلاغات',
        'subtitle': 'بلاغات ومؤشرات الاستجابة',
        'icon': Icons.assignment_rounded,
        'route': AppRouteKeys.reports,
        'notificationCount': 2,
      },
      {
        'name': 'مراقبة الأسطول',
        'subtitle': 'تتبع المركبات والجاهزية',
        'icon': Icons.local_shipping_rounded,
        'route': AppRouteKeys.fleet,
        'notificationCount': null,
      },
      {
        'name': 'إدارة المناوبات',
        'subtitle': 'الكوادر والجداول اليومية',
        'icon': Icons.groups_rounded,
        'route': AppRouteKeys.shifts,
        'notificationCount': null,
      },
      {
        'name': 'توزيع الجدول',
        'subtitle': 'توزيع الإسعافات على المراكز',
        'icon': Icons.grid_view_rounded,
        'route': AppRouteKeys.schedule,
        'notificationCount': null,
      },
      {
        'name': 'طلبات التبديل',
        'subtitle': 'طلبات بانتظار المعالجة',
        'icon': Icons.swap_horiz_rounded,
        'route': AppRouteKeys.exchange,
        'notificationCount': 3,
      },
      {
        'name': 'الإعدادات',
        'subtitle': 'تخصيص النظام والتفضيلات',
        'icon': Icons.settings_rounded,
        'route': AppRouteKeys.settings,
        'notificationCount': null,
      },
    ];

    final user = ref.watch(authNotifierProvider).user;
    final role = user?.role;

    if (role != 'admin') {
      navItems.removeWhere((item) => item['route'] != AppRouteKeys.overview);
    }

    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.98),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.82),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.emergency_share_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xFF7CFFB2),
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'نشط',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'EORMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'منصة قيادة غرفة العمليات ومراقبة الاستجابة الإسعافية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        height: 1.45,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SidebarStatChip(
                            label: 'المهام',
                            value: '24',
                            icon: Icons.bolt_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SidebarStatChip(
                            label: 'المراكز',
                            value: '08',
                            icon: Icons.hub_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: OptimizedListView<Map<String, dynamic>>(
                  items: navItems,
                  itemBuilder: (context, item, index) {
                    final route = item['route'] as String;
                    final isScheduleItem = route == AppRouteKeys.schedule;
                    final isActive = currentRoute == route ||
                        currentRoute.startsWith('$route/') ||
                        (route == AppRouteKeys.overview &&
                            (currentRoute == AppRouteKeys.dashboard ||
                                currentRoute == AppRouteKeys.overview));

                    return FadeSlideInAnimation(
                      duration: Duration(milliseconds: 180 + (index * 45)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: _SidebarNavTile(
                          title: item['name'] as String,
                          subtitle: item['subtitle'] as String,
                          icon: item['icon'] as IconData,
                          isActive: isActive,
                          badgeCount: item['notificationCount'] as int?,
                          isCompact: isCompact,
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }

                            if (isScheduleItem) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AmbulanceDistributionScreen(),
                                ),
                              );
                              return;
                            }

                            context.go(route);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AppCard(
                  margin: EdgeInsets.zero,
                  borderRadius: 22,
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: isDarkMode
                              ? Colors.amber.shade600
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDarkMode ? 'الوضع الليلي' : 'الوضع النهاري',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              'اضغط للتبديل بين أنماط العرض',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.75),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isDarkMode,
                        onChanged: (_) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final int? badgeCount;
  final VoidCallback onTap;
  final bool isCompact;

  const _SidebarNavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive
                ? activeColor.withOpacity(0.10)
                : theme.colorScheme.surface.withOpacity(0.64),
            border: Border.all(
              color: isActive
                  ? activeColor.withOpacity(0.26)
                  : theme.dividerColor.withOpacity(0.08),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isActive
                      ? activeColor
                      : theme.colorScheme.primary.withOpacity(0.08),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : activeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? activeColor
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeCount != null)
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.iconTheme.color?.withOpacity(0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SidebarStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}