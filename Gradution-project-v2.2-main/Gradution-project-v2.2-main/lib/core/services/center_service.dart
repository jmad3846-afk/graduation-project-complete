// ignore_for_file: avoid_print

import '../models/center_model.dart';
import '../network/api_service.dart';

class CenterService {
  final ApiService _apiService;

  CenterService(this._apiService);

  Future<List<CenterModel>> fetchCenters() async {
    try {
      final response = await _apiService.client.get('/centers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CenterModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('fetchCenters error: $e');
    }
    return [];
  }
}
