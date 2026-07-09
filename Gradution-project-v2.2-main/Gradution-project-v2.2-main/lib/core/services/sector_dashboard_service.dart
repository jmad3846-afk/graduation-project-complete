import 'package:dio/dio.dart';
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
}
