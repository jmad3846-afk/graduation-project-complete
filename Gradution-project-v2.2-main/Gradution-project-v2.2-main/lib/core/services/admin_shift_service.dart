// ignore_for_file: avoid_print

import '../models/schedule_row_model.dart';
import '../models/shift_plan_model.dart';
import '../models/shift_statistics_model.dart';
import '../models/swap_request_model.dart';
import '../network/api_service.dart';

class AdminShiftService {
  final ApiService _apiService;

  AdminShiftService(this._apiService);

  // ─── Statistics ───────────────────────────────────────────────────────────

  Future<ShiftStatisticsModel> fetchStatistics() async {
    try {
      final response =
          await _apiService.client.get('/admin/shift-statistics/current-plan');
      if (response.statusCode == 200) {
        return ShiftStatisticsModel.fromJson(
            response.data as Map<String, dynamic>);
      }
    } catch (e) {
      print('fetchStatistics error: $e');
    }
    return ShiftStatisticsModel.empty();
  }

  // ─── Shift Plans ──────────────────────────────────────────────────────────

  Future<List<ShiftPlanModel>> fetchPlans() async {
    try {
      final response = await _apiService.client.get('/admin/shift-plans');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        return data
            .map((e) => ShiftPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('fetchPlans error: $e');
    }
    return [];
  }

  Future<bool> createPlan(int month, int year) async {
    try {
      final response = await _apiService.client.post('/admin/shift-plans',
          data: {'month': month, 'year': year});
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('createPlan error: $e');
      return false;
    }
  }

  Future<bool> _planAction(int id, String action) async {
    try {
      final response =
          await _apiService.client.post('/admin/shift-plans/$id/$action');
      return response.statusCode == 200;
    } catch (e) {
      print('planAction[$action] error: $e');
      return false;
    }
  }

  Future<bool> startLeaderPoll(int id) => _planAction(id, 'start-leader-poll');
  Future<bool> startScoutPoll(int id) => _planAction(id, 'start-scout-poll');
  Future<bool> startParamedicPoll(int id) =>
      _planAction(id, 'start-paramedic-poll');
  Future<bool> buildPlan(int id) => _planAction(id, 'build');
  Future<bool> publishPlan(int id) => _planAction(id, 'publish');
  Future<bool> closePlan(int id) => _planAction(id, 'close');

  // ─── Schedule Distribution ────────────────────────────────────────────────

  Future<List<ScheduleRowModel>> fetchSchedule(int planId) async {
    try {
      final response =
          await _apiService.client.get('/admin/shift-plans/$planId/schedule');
      if (response.statusCode == 200) {
        final List<dynamic> rows = response.data['rows'] ?? [];
        return rows
            .map((e) => ScheduleRowModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('fetchSchedule error: $e');
    }
    return [];
  }

  Future<bool> sendSchedule(int planId) async {
    try {
      final response = await _apiService.client
          .post('/admin/shift-plans/$planId/send-schedule');
      return response.statusCode == 200;
    } catch (e) {
      print('sendSchedule error: $e');
      return false;
    }
  }

  // ─── Swap Requests ────────────────────────────────────────────────────────

  Future<List<SwapRequestModel>> fetchSwapRequests() async {
    try {
      final response =
          await _apiService.client.get('/shift-requests');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        return data
            .map((e) => SwapRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('fetchSwapRequests error: $e');
    }
    return [];
  }

  Future<bool> approveSwapRequest(int requestId) async {
    try {
      final response = await _apiService.client
          .post('/admin/shift-requests/$requestId/approve');
      return response.statusCode == 200;
    } catch (e) {
      print('approveSwapRequest error: $e');
      return false;
    }
  }

  Future<bool> rejectSwapRequest(int requestId) async {
    try {
      final response = await _apiService.client
          .post('/shift-requests/$requestId/reject');
      return response.statusCode == 200;
    } catch (e) {
      print('rejectSwapRequest error: $e');
      return false;
    }
  }
}
