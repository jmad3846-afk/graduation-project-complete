import 'package:dio/dio.dart';
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

  /// Assigns a waiting case to a center. Throws with the backend's message
  /// (e.g. team-not-ready) on failure so the caller can show it to the user.
  Future<void> assignCenter(int caseId, int centerId) async {
    try {
      await _apiService.client.patch(
        '/cases/$caseId/center',
        data: {'center_id': centerId},
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Failed to assign center';
      if (data is Map && data['errors'] is Map) {
        final errors = (data['errors'] as Map).values.expand((v) => v is List ? v : [v]);
        if (errors.isNotEmpty) message = errors.first.toString();
      } else if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
      throw Exception(message);
    }
  }
}
