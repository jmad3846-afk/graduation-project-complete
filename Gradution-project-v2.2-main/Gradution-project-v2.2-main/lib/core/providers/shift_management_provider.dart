import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_row_model.dart';
import '../models/shift_plan_model.dart';
import '../models/shift_statistics_model.dart';
import '../models/swap_request_model.dart';
import '../services/admin_shift_service.dart';
import 'service_providers.dart';

// ── Service provider ─────────────────────────────────────────────────────────

final adminShiftServiceProvider = Provider<AdminShiftService>(
    (ref) => AdminShiftService(ref.read(apiProvider)));

// ── State class ──────────────────────────────────────────────────────────────

class ShiftManagementState {
  final ShiftStatisticsModel statistics;
  final List<ShiftPlanModel> plans;
  final List<SwapRequestModel> swapRequests;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final int? justPublishedPlanId;

  const ShiftManagementState({
    required this.statistics,
    required this.plans,
    required this.swapRequests,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.justPublishedPlanId,
  });

  ShiftManagementState copyWith({
    ShiftStatisticsModel? statistics,
    List<ShiftPlanModel>? plans,
    List<SwapRequestModel>? swapRequests,
    bool? isLoading,
    String? error,
    String? successMessage,
    int? justPublishedPlanId,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearJustPublished = false,
  }) {
    return ShiftManagementState(
      statistics: statistics ?? this.statistics,
      plans: plans ?? this.plans,
      swapRequests: swapRequests ?? this.swapRequests,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      justPublishedPlanId: clearJustPublished
          ? null
          : (justPublishedPlanId ?? this.justPublishedPlanId),
    );
  }

  factory ShiftManagementState.initial() => ShiftManagementState(
        statistics: ShiftStatisticsModel.empty(),
        plans: [],
        swapRequests: [],
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class ShiftManagementNotifier extends StateNotifier<ShiftManagementState> {
  final AdminShiftService _service;

  ShiftManagementNotifier(this._service)
      : super(ShiftManagementState.initial());

  // ── Load all data ─────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.fetchStatistics(),
        _service.fetchPlans(),
        _service.fetchSwapRequests(),
      ]);
      state = state.copyWith(
        isLoading: false,
        statistics: results[0] as ShiftStatisticsModel,
        plans: results[1] as List<ShiftPlanModel>,
        swapRequests: results[2] as List<SwapRequestModel>,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'فشل تحميل البيانات: ${e.toString()}');
    }
  }

  Future<void> refreshPlans() async {
    final plans = await _service.fetchPlans();
    state = state.copyWith(plans: plans);
  }

  Future<void> refreshStats() async {
    final stats = await _service.fetchStatistics();
    state = state.copyWith(statistics: stats);
  }

  Future<void> refreshSwapRequests() async {
    final reqs = await _service.fetchSwapRequests();
    state = state.copyWith(swapRequests: reqs);
  }

  // ── Create plan ───────────────────────────────────────────────────────────

  Future<bool> createPlan(int month, int year) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await _service.createPlan(month, year);
    if (ok) {
      await Future.wait([refreshPlans(), refreshStats()]);
      state = state.copyWith(
          isLoading: false, successMessage: 'تم إنشاء الخطة بنجاح');
    } else {
      state = state.copyWith(isLoading: false, error: 'فشل إنشاء الخطة');
    }
    return ok;
  }

  // ── Plan actions ──────────────────────────────────────────────────────────

  Future<void> _runPlanAction(
      int id, Future<bool> Function() action, String successMsg) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await action();
    if (ok) {
      await refreshPlans();
      state = state.copyWith(isLoading: false, successMessage: successMsg);
    } else {
      state = state.copyWith(isLoading: false, error: 'فشلت العملية');
    }
  }

  Future<void> startLeaderPoll(int id) =>
      _runPlanAction(id, () => _service.startLeaderPoll(id),
          'تم بدء استطلاع القادة');

  Future<void> startScoutPoll(int id) =>
      _runPlanAction(id, () => _service.startScoutPoll(id),
          'تم بدء استطلاع الكشافة');

  Future<void> startParamedicPoll(int id) =>
      _runPlanAction(id, () => _service.startParamedicPoll(id),
          'تم بدء استطلاع المسعفين');

  Future<void> buildPlan(int id) =>
      _runPlanAction(id, () => _service.buildPlan(id), 'تم بناء الجدول');

  Future<void> publishPlan(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await _service.publishPlan(id);
    if (ok) {
      await refreshPlans();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'تم نشر الجدول',
        justPublishedPlanId: id,
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'فشلت العملية');
    }
  }

  Future<void> closePlan(int id) =>
      _runPlanAction(id, () => _service.closePlan(id), 'تم إغلاق الخطة');

  // ── Schedule distribution ─────────────────────────────────────────────────

  Future<List<ScheduleRowModel>> fetchSchedule(int planId) =>
      _service.fetchSchedule(planId);

  Future<bool> sendSchedule(int planId) => _service.sendSchedule(planId);

  // ── Swap requests ──────────────────────────────────────────────────────────

  Future<void> approveSwap(int requestId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await _service.approveSwapRequest(requestId);
    if (ok) {
      await Future.wait([refreshSwapRequests(), refreshStats()]);
      state =
          state.copyWith(isLoading: false, successMessage: 'تم اعتماد الطلب');
    } else {
      state = state.copyWith(isLoading: false, error: 'فشل اعتماد الطلب');
    }
  }

  Future<void> rejectSwap(int requestId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await _service.rejectSwapRequest(requestId);
    if (ok) {
      await refreshSwapRequests();
      state = state.copyWith(isLoading: false, successMessage: 'تم رفض الطلب');
    } else {
      state = state.copyWith(isLoading: false, error: 'فشل رفض الطلب');
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  void clearJustPublished() {
    state = state.copyWith(clearJustPublished: true);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final shiftManagementProvider = StateNotifierProvider<ShiftManagementNotifier,
    ShiftManagementState>((ref) {
  return ShiftManagementNotifier(ref.read(adminShiftServiceProvider));
});
