import 'package:flutter/material.dart';
import 'components/center_main_content.dart';
import 'components/center_sidebar.dart';

class CenterPage extends StatelessWidget {
  const CenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز الإسعاف 140 - إدارة العمليات'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLargeScreen = constraints.maxWidth > 900;

            if (isLargeScreen) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: CenterMainContent(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: CenterSidebar(),
                    ),
                  ),
                ],
              );
            }

            return const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CenterMainContent(),
                  SizedBox(height: 20),
                  CenterSidebar(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
