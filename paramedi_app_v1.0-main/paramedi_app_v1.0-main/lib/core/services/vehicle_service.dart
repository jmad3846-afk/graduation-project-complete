
import '../models/vehicle_model.dart';
import '../network/api_service.dart';

class VehicleService {
  final ApiService _apiService;

  VehicleService(this._apiService);

  Future<List<VehicleModel>> fetchVehicles() async {
    try {
      final response = await _apiService.client.get('/vehicles');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch vehicles error: $e');
    }
    return [];
  }
}
