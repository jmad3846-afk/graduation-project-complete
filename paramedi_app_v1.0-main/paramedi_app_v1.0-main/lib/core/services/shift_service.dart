
import '../models/shift_assignment_model.dart';
import '../models/shift_poll_model.dart';
import '../models/shift_request_model.dart';
import '../network/api_service.dart';

class ShiftService {
  final ApiService _apiService;

  ShiftService(this._apiService);

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic> && payload['data'] is List) {
      return payload['data'];
    }
    return const [];
  }

  Future<ShiftPollModel?> fetchCurrentPoll() async {
    try {
      final response = await _apiService.client.get('/shift-polls/current');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic> && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return ShiftPollModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Fetch current poll error: $e');
    }
    return null;
  }

  Future<void> submitPoll(int pollId, List<ShiftSelection> preferredShifts, List<ShiftSelection> unavailableShifts) async {
    await _apiService.client.post('/shift-polls/$pollId/submit', data: {
      'preferred_shifts': preferredShifts.map((e) => e.toJson()).toList(),
      'unavailable_shifts': unavailableShifts.map((e) => e.toJson()).toList(),
    });
  }

  Future<List<ShiftAssignmentModel>> fetchMySchedule() async {
    try {
      final response = await _apiService.client.get('/my-schedule');
      if (response.statusCode == 200) {
        return _extractList(response.data)
            .map((json) => ShiftAssignmentModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      print('Fetch schedule error: $e');
    }
    return const [];
  }

  Future<List<ShiftRequestModel>> fetchShiftRequests() async {
    try {
      final response = await _apiService.client.get('/shift-requests');
      if (response.statusCode == 200) {
        return _extractList(response.data)
            .map((json) => ShiftRequestModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      print('Fetch shift requests error: $e');
    }
    return const [];
  }

  Future<void> createSwapRequest({
    required int requesterAssignmentId,
    required int targetAssignmentId,
    String? reason,
  }) async {
    await _apiService.client.post('/shift-requests', data: {
      'requester_assignment_id': requesterAssignmentId,
      'target_assignment_id': targetAssignmentId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
  }
}
