import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/providers/auth_provider.dart';
import 'package:ems_op_room/presentation/CEO/CEO.dart';
import 'package:ems_op_room/presentation/center/center.dart';
import 'package:ems_op_room/presentation/login/login.dart';
import 'package:ems_op_room/presentation/welcome/welcome.dart';
import 'package:ems_op_room/presentation/lidar/lidar.dart';
import 'package:ems_op_room/presentation/radio/radio&car.dart';
import 'package:ems_op_room/presentation/reports/reports_page.dart';
import 'package:ems_op_room/presentation/settings/setting.dart';
import 'package:ems_op_room/presentation/CEO/components/fleet_monitoring_screen.dart';
import 'package:ems_op_room/presentation/CEO/components/shift_exchange_screen.dart';
import 'package:ems_op_room/presentation/CEO/components/shift_management_page.dart';
import 'package:ems_op_room/presentation/CEO/components/placeholder_screen.dart';

// Router Keys
class AppRouteKeys {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  // المسارات الفرعية للوحة التحكم (تحت /dashboard)
  static const String overview = '/dashboard/overview';
  static const String fleet = '/dashboard/fleet';
  static const String shifts = '/dashboard/shifts';
  static const String schedule = '/dashboard/schedule';
  static const String exchange = '/dashboard/exchange';
  static const String radiocar = '/radiocar';
  static const String lidar = '/lidar';
  static const String center = '/center';
  static const String reports = '/reports';
  static const String settings = '/settings';
}

// Custom Transition for Pages
class CustomTransition extends CustomTransitionPage {
  CustomTransition({required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
        );
}



// App Router Configuration
final appRouter = GoRouter(
  initialLocation: AppRouteKeys.login,
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    try {
      final user = ProviderScope.containerOf(context).read(authNotifierProvider).user;
      final role = user?.role;
      final isGoingToLogin = state.uri.toString() == AppRouteKeys.login;

      if (user == null) {
        return isGoingToLogin ? null : AppRouteKeys.login;
      }

      if (isGoingToLogin) {
        return null;
      }

      final path = state.uri.toString();

      if (role == 'admin') return null;

      if (role == 'manager') {
        if (!path.startsWith(AppRouteKeys.dashboard) && path != AppRouteKeys.login) {
          return AppRouteKeys.dashboard;
        }
      } else if (role == 'sector_leader') {
        if (path != AppRouteKeys.lidar && path != AppRouteKeys.login) {
          return AppRouteKeys.lidar;
        }
      } else if (role == 'center_manager') {
        if (path != AppRouteKeys.center && path != AppRouteKeys.login) {
          return AppRouteKeys.center;
        }
      } else if (role == 'operations') {
        if (path != AppRouteKeys.reports && path != AppRouteKeys.login) {
          return AppRouteKeys.reports;
        }
      } else if (role == 'radio') {
        if (path != AppRouteKeys.radiocar && path != AppRouteKeys.login) {
          return AppRouteKeys.radiocar;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  },
  routes: [
    // Login Route
    GoRoute(
      path: AppRouteKeys.login,
      name: 'Login',
      pageBuilder: (context, state) => CustomTransition(
        child: const LoginPage(),
      ),
    ),

    // Welcome Route
    GoRoute(
      path: AppRouteKeys.welcome,
      name: 'Welcome',
      pageBuilder: (context, state) => CustomTransition(
        child: const WelcomePage(),
      ),
    ),

    // Dashboard Routes
    GoRoute(
      path: AppRouteKeys.dashboard,
      name: 'Dashboard',
      pageBuilder: (context, state) => CustomTransition(
        child: const OverviewDashboardScreen(),
      ),
      routes: [
        GoRoute(
          // المسار الفرعي لا يجب أن يبدأ بـ '/'
          path: 'overview',
          name: 'Overview',
          pageBuilder: (context, state) => CustomTransition(
            child: const OverviewDashboardScreen(),
          ),
        ),
        GoRoute(
          path: 'fleet',
          name: 'Fleet Monitoring',
          pageBuilder: (context, state) => CustomTransition(
            child: const FleetMonitoringPage(),
          ),
        ),
        GoRoute(
          path: 'shifts',
          name: 'Shift Management',
          pageBuilder: (context, state) => CustomTransition(
            child: const ShiftManagementPage(),
          ),
        ),
        GoRoute(
          path: 'schedule',
          name: 'Schedule Distribution',
          pageBuilder: (context, state) => CustomTransition(
            child: const PlaceholderScreen(title: 'توزيع الجدول'),
          ),
        ),
        GoRoute(
          path: 'exchange',
          name: 'Shift Exchange',
          pageBuilder: (context, state) => CustomTransition(
            child: const ShiftExchangePage(),
          ),
        ),
      ],
    ),

    // Radio & Car Route
    GoRoute(
      path: AppRouteKeys.radiocar,
      name: 'Radio & Car',
      pageBuilder: (context, state) => CustomTransition(
        child: const RadioCarPage(),
      ),
    ),

    // Lidar Route
    GoRoute(
      path: AppRouteKeys.lidar,
      name: 'Lidar',
      pageBuilder: (context, state) => CustomTransition(
        child: const Lidar(),
      ),
    ),

    // Center Route
    GoRoute(
      path: AppRouteKeys.center,
      name: 'Center',
      pageBuilder: (context, state) => CustomTransition(
        child: const CenterPage(),
      ),
    ),

    // Reports Route
    GoRoute(
      path: AppRouteKeys.reports,
      name: 'Reports',
      pageBuilder: (context, state) => CustomTransition(
        child: const ReportsPage(),
      ),
    ),

    // Settings Route
    GoRoute(
      path: AppRouteKeys.settings,
      name: 'Settings',
      pageBuilder: (context, state) => CustomTransition(
        child: const SettingPage(),
      ),
    ),
  ],

  // Error Handler
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.error}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRouteKeys.dashboard),
            child: const Text('العودة للرئيسية'),
          ),
        ],
      ),
    ),
  ),
);

// Navigation Helper Methods
class NavigationHelper {
  static void navigateTo(BuildContext context, String path) {
    context.go(path);
  }

  static void navigateToNamed(BuildContext context, String name) {
    context.goNamed(name);
  }

  static void push(BuildContext context, String path) {
    context.push(path);
  }

  static void pushNamed(BuildContext context, String name) {
    context.pushNamed(name);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static void popUntil(BuildContext context, String path) {
    while (context.canPop()) {
      context.pop();
    }
    context.go(path);
  }
}
