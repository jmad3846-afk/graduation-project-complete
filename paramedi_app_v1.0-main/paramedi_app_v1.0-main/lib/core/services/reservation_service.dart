import 'package:dio/dio.dart';

import '../models/reservation_model.dart';
import '../network/api_service.dart';

/// Thrown when a reservation attempt loses a race to another user
/// (backend responded 409 - slot already reserved).
class ReservationConflictException implements Exception {
  final String message;
  ReservationConflictException([this.message = 'This shift has already been reserved.']);
}

class ReservationService {
  final ApiService _apiService;

  ReservationService(this._apiService);

  Future<int> reserve({
    required int shiftPlanId,
    required int centerId,
    required int day,
    required String shiftType,
    required String rank,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/shift-plans/$shiftPlanId/reserve',
        data: {
          'center_id': centerId,
          'day': day,
          'shift_type': shiftType,
          'rank': rank,
        },
      );
      return response.data['reservation_id'] as int;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ReservationConflictException();
      }
      rethrow;
    }
  }

  Future<void> release({
    required int shiftPlanId,
    required int reservationId,
  }) async {
    await _apiService.client.post(
      '/shift-plans/$shiftPlanId/release',
      data: {'reservation_id': reservationId},
    );
  }

  Future<void> confirm({
    required int shiftPlanId,
    required int reservationId,
  }) async {
    await _apiService.client.post(
      '/shift-plans/$shiftPlanId/confirm',
      data: {'reservation_id': reservationId},
    );
  }

  Future<List<ReservationModel>> currentReservations(int shiftPlanId) async {
    final response = await _apiService.client.get('/shift-plans/$shiftPlanId/reservations');
    final data = response.data;
    if (data is List) {
      return data
          .map((json) => ReservationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return const [];
  }
}
