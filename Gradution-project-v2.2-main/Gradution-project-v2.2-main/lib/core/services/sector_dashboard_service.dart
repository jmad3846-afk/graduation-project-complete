import 'package:ems_op_room/core/network/api_service.dart';

class SectorDashboardService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> fetchDashboard() async {
    final resp = await _api.client.get('/sector-commander/dashboard');
    if (resp.statusCode == 200) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw Exception('Failed to load dashboard: ${resp.statusCode}');
  }

  /// Live readiness (leader/scout/paramedic check-in) of the team on today's
  /// shift at [centerId]. Returns null if no shift is scheduled today.
  Future<Map<String, dynamic>?> fetchTeamStatus(int centerId) async {
    final resp = await _api.client.get('/sector-commander/centers/$centerId/team-status');
    if (resp.statusCode == 200) {
      final data = resp.data['team_status'];
      return data == null ? null : Map<String, dynamic>.from(data as Map);
    }
    throw Exception('Failed to load team status: ${resp.statusCode}');
  }
}
