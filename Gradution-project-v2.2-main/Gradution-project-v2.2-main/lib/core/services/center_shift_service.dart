// ignore_for_file: avoid_print

import '../models/upcoming_shift_model.dart';
import '../network/api_service.dart';

class CenterShiftService {
  final ApiService _apiService;

  CenterShiftService(this._apiService);

  Future<UpcomingShiftModel?> fetchUpcomingShift({int? afterShiftId, int? centerId}) async {
    try {
      final queryParameters = <String, dynamic>{
        if (afterShiftId != null) 'after_shift_id': afterShiftId,
        if (centerId != null) 'center_id': centerId,
      };
      final response = await _apiService.client.get(
        '/center/upcoming-shift',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      if (response.statusCode == 200) {
        final data = response.data['shift'];
        if (data == null) return null;
        return UpcomingShiftModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      print('fetchUpcomingShift error: $e');
    }
    return null;
  }

  Future<bool> checkIn(int assignmentId) async {
    try {
      final response = await _apiService.client
          .post('/shift-assignments/$assignmentId/check-in');
      return response.statusCode == 200;
    } catch (e) {
      print('checkIn error: $e');
      return false;
    }
  }
}
