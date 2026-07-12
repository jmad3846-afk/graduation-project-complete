import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/case_model.dart';
import '../network/api_service.dart';

String _dioErrorMessage(DioException e, String fallback) {
  final data = e.response?.data;
  if (data is Map && data['errors'] is Map) {
    final errors = (data['errors'] as Map).values.expand((v) => v is List ? v : [v]);
    if (errors.isNotEmpty) return errors.first.toString();
  } else if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  return fallback;
}

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

  /// Raw case JSON (as shaped by the backend's CaseResource), used by the
  /// Radio interface which needs fields (movement_log, center, etc.) the
  /// thin CaseModel doesn't carry.
  Future<List<Map<String, dynamic>>> fetchCasesRaw() async {
    final response = await _apiService.client.get('/cases');
    final List<dynamic> data = response.data;
    return data.map((json) => Map<String, dynamic>.from(json as Map)).toList();
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
      throw Exception(_dioErrorMessage(e, 'Failed to assign center'));
    }
  }

  /// Updates plain case fields, e.g. destination_hospital.
  Future<void> updateCase(int caseId, Map<String, dynamic> data) async {
    try {
      await _apiService.client.put('/cases/$caseId', data: data);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Failed to update case'));
    }
  }

  /// Upserts the Radio interface's movement-log form fields for a case:
  /// vehicle timestamps (HH:mm), team leader name, whether transport
  /// happened, and the reason if not. Only non-null fields in [data] are
  /// sent, so a single-field edit doesn't clobber the rest.
  Future<void> saveMovementLog(int caseId, Map<String, dynamic> data) async {
    try {
      await _apiService.client.post('/movement_logs/save', data: {
        'case_id': caseId,
        ...data,
      });
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Failed to save movement log'));
    }
  }

  /// Moves a case to 'closed', walking through whatever intermediate
  /// statuses are required. Used by the Radio interface's "Finish Case".
  Future<void> finishCase(int caseId) async {
    try {
      await _apiService.client.post('/cases/$caseId/finish');
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Failed to finish case'));
    }
  }

  /// Uploads the liability-waiver photo and archives the case. The backend
  /// rejects this with a 422 until the case's status is 'closed', which is
  /// exactly the "can't archive until photo is uploaded" gate (finishCase
  /// must be called first).
  Future<void> uploadArchive(int caseId, Uint8List photoBytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'case_id': caseId,
        'disclaimer_image': MultipartFile.fromBytes(photoBytes, filename: filename),
      });
      await _apiService.client.post('/archives', data: formData);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Failed to archive case'));
    }
  }
}
