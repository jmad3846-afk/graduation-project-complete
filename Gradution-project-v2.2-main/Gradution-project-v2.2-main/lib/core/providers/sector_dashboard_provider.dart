import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sector_dashboard_service.dart';

final sectorDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = SectorDashboardService();
  return await service.fetchDashboard();
});
