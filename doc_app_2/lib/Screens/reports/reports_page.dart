import 'package:flutter/material.dart';
import 'components/reports_page_body.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportsBody(),
    );
  }
}

