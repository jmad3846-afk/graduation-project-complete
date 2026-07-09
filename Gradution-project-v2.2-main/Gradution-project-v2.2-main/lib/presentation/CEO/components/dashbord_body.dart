import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems_op_room/core/widgets/performance_widgets.dart';
import 'package:ems_op_room/core/widgets/animation_widgets.dart';
import 'package:ems_op_room/presentation/CEO/components/dashbord_sidebar.dart';
import 'package:ems_op_room/presentation/CEO/components/filter_panel.dart';
import 'package:ems_op_room/presentation/CEO/components/main_content.dart';

class DashboardBody extends ConsumerWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        drawer: const DashboardSidebar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLargeScreen = constraints.maxWidth > 900;

            if (isLargeScreen) {
              return Row(
                children: [
                  const DashboardSidebar(),
                  Expanded(
                    flex: 4,
                    child: OptimizedContainer(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SingleChildScrollView(
                        child: const FadeInAnimation(
                          child: MainContent(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: OptimizedContainer(
                      padding: const EdgeInsets.all(20),
                      child: const FadeInAnimation(
                        child: FilterPanel(),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const FadeInAnimation(
                      child: MainContent(isMobile: true),
                    ),
                    const SizedBox(height: 20),
                    const FadeInAnimation(
                      child: FilterPanel(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
