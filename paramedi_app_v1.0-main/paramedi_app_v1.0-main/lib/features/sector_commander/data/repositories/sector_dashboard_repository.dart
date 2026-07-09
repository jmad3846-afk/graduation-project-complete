import '../models/sector_dashboard_model.dart';
import '../services/sector_dashboard_service.dart';

class SectorDashboardRepository {
  final SectorDashboardService _service;

  SectorDashboardRepository(this._service);

  Future<SectorDashboardModel?> getDashboard() async {
    try {
      final response = await _service.fetchDashboard();
      if (response.statusCode == 200) {
        return SectorDashboardModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      // ignore: avoid_print
      print('SectorDashboardRepository.getDashboard error: $e');
    }
    return null;
  }
}
