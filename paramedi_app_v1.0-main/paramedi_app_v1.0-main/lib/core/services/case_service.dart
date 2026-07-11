import 'package:flutter/foundation.dart';
import '../models/case_model.dart';
import '../network/api_service.dart';

class CaseService {
  final ApiService _apiService;

  CaseService(this._apiService);

  Future<List<CaseModel>> fetchCases() async {
    try {
      final response = await _apiService.client.get('/cases');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CaseModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch cases error: $e');
    }
    return [];
  }
}
