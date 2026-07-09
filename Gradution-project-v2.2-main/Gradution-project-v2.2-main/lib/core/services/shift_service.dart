
import '../models/shift_model.dart';
import '../network/api_service.dart';

class ShiftService {
  final ApiService _apiService;

  ShiftService(this._apiService);

  Future<List<ShiftModel>> fetchAll() async {
    // FUTURE_INTEGRATION_ASSUMPTION: endpoint /shifts missing
    // Currently returns an empty list as Laravel does not implement GET /shifts
    try {
      final response = await _apiService.client.get('/shifts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShiftModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch shifts error: $e');
    }
    return [];
  }
}
