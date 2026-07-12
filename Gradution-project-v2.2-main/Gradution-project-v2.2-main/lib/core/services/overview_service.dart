import 'package:ems_op_room/core/network/api_service.dart';

class OverviewService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> fetchDashboard() async {
    final resp = await _api.client.get('/overview/dashboard');
    if (resp.statusCode == 200) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw Exception('Failed to load overview dashboard: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> fetchStatistics({
    required int centerId,
    required String period,
  }) async {
    final resp = await _api.client.get(
      '/overview/statistics',
      queryParameters: {'center_id': centerId, 'period': period},
    );
    if (resp.statusCode == 200) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw Exception('Failed to load statistics: ${resp.statusCode}');
  }
}
