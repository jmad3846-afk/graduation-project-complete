import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/overview_service.dart';

final overviewDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = OverviewService();
  return await service.fetchDashboard();
});

class CenterStatsParams {
  final int centerId;
  final String period;
  const CenterStatsParams({required this.centerId, required this.period});

  @override
  bool operator ==(Object other) =>
      other is CenterStatsParams && other.centerId == centerId && other.period == period;

  @override
  int get hashCode => Object.hash(centerId, period);
}

final centerStatisticsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, CenterStatsParams>((ref, params) async {
  final service = OverviewService();
  return await service.fetchStatistics(centerId: params.centerId, period: params.period);
});
