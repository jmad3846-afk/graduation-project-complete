import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';

class SectorDashboardService {
  final ApiService _apiService;

  SectorDashboardService(this._apiService);

  Future<Response> fetchDashboard() async {
    return await _apiService.client.get('/sector-commander/dashboard');
  }
}
