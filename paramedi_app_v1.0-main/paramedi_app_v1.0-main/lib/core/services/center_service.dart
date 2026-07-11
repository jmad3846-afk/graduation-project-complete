import 'package:flutter/foundation.dart';
import '../models/center_model.dart';
import '../network/api_service.dart';

class CenterService {
  final ApiService _apiService;

  CenterService(this._apiService);

  Future<List<CenterModel>> fetchCenters() async {
    try {
      final response = await _apiService.client.get('/centers');
      final data = response.data;
      if (data is List) {
        return data
            .map((json) => CenterModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('Fetch centers error: $e');
    }
    return const [];
  }
}
