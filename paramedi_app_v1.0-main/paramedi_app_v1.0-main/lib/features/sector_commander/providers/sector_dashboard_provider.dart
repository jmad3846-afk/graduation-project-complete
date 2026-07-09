import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sector_dashboard_model.dart';
import '../data/services/sector_dashboard_service.dart';
import '../data/repositories/sector_dashboard_repository.dart';
import '../../../../core/network/api_service.dart';

final sectorDashboardProvider = StateNotifierProvider<SectorDashboardNotifier, AsyncValue<SectorDashboardModel?>>(
  (ref) => SectorDashboardNotifier(),
);

class SectorDashboardNotifier extends StateNotifier<AsyncValue<SectorDashboardModel?>> {
  SectorDashboardNotifier() : super(const AsyncValue.loading()) {
    fetchDashboard();
  }

  final ApiService _apiService = ApiService();

  Future<void> fetchDashboard() async {
    state = const AsyncValue.loading();
    final service = SectorDashboardService(_apiService);
    final repo = SectorDashboardRepository(service);
    try {
      final data = await repo.getDashboard();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetchDashboard();
}
