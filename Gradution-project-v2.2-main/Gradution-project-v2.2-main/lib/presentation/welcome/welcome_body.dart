// ignore_for_file: unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';
import 'components/welcome_button_card.dart';
import 'models/welcome_button_model.dart';
import 'package:go_router/go_router.dart';

class WelcomePageBody extends StatelessWidget {
  const WelcomePageBody({super.key});

  int _crossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 800) return 3;
    if (width > 500) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _crossAxisCount(screenWidth);

    final List<WelcomeButtonModel> buttons = [
      WelcomeButtonModel(
        title: 'Lidar',
        subtitle: 'Manage and organize op room',
        icon: Icons.leaderboard,
        onTap: () {
          context.go('/lidar');
          print('Lidar button pressed');
        },
      ),
      WelcomeButtonModel(
        title: 'Reports',
        subtitle: 'Submit and manage reports',
        icon: Icons.assignment,
        onTap: () {
          context.go('/reports');
          print('Reports button pressed');
        },
      ),
      WelcomeButtonModel(
        title: 'Radio',
        subtitle: 'Manage sectors and radio message',
        icon: Icons.radio,
        onTap: () {
          context.go('/radiocar');
          print('Radio button pressed');
        },
      ),
      WelcomeButtonModel(
        title: 'Center',
        subtitle: 'Manage main center',
        icon: Icons.house_sharp,
        onTap: () {
          context.go('/center');
          print('Center button pressed');
        },
      ),
      WelcomeButtonModel(
        title: 'Settings',
        subtitle: 'Customize system settings',
        icon: Icons.settings,
        onTap: () {
          context.go('/settings');
          print('Settings button pressed');
        },
      ),
      WelcomeButtonModel(
        title: 'Dashboard',
        subtitle: 'View system overview and statistics',
        icon: Icons.dashboard,
        onTap: () {
          context.go('/dashboard');
          print('Dashboard button pressed');
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemCount: buttons.length,
              itemBuilder: (_, index) {
                return WelcomeButtonCard(data: buttons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
