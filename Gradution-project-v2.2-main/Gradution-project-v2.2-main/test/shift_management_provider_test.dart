import 'package:flutter_test/flutter_test.dart';
import 'package:ems_op_room/core/models/shift_plan_model.dart';
import 'package:ems_op_room/core/models/shift_statistics_model.dart';
import 'package:ems_op_room/core/models/swap_request_model.dart';
import 'package:ems_op_room/core/network/api_service.dart';
import 'package:ems_op_room/core/providers/shift_management_provider.dart';
import 'package:ems_op_room/core/services/admin_shift_service.dart';

/// Fakes the network boundary only. Everything above this (provider,
/// notifier, state) runs unmodified, exactly as it does against the real
/// backend — this isolates whether the Flutter state chain itself ever
/// leaves `isLoading` stuck or fails to pick up the fresh plan status
/// after Build, independent of any backend behavior.
class _FakeAdminShiftService extends AdminShiftService {
  _FakeAdminShiftService() : super(ApiService());

  String planStatus = 'polling_paramedics';
  int buildCallCount = 0;

  @override
  Future<List<ShiftPlanModel>> fetchPlans() async {
    return [
      ShiftPlanModel(
        id: 1,
        month: 7,
        year: 2026,
        status: planStatus,
        createdAt: DateTime(2026, 7, 1),
      ),
    ];
  }

  @override
  Future<ShiftStatisticsModel> fetchStatistics() async =>
      ShiftStatisticsModel.empty();

  @override
  Future<List<SwapRequestModel>> fetchSwapRequests() async => [];

  @override
  Future<bool> buildPlan(int id) async {
    buildCallCount++;
    // Simulate the real backend: build takes a moment, then the plan's
    // status flips from polling_paramedics to building server-side.
    await Future.delayed(const Duration(milliseconds: 50));
    planStatus = 'building';
    return true;
  }
}

void main() {
  test(
    'buildPlan clears isLoading and refreshes plans to the latest status',
    () async {
      final fakeService = _FakeAdminShiftService();
      final notifier = ShiftManagementNotifier(fakeService);

      // Preload plans the way loadAll() would, so state.plans starts non-empty
      // with the pre-build status, mirroring what the UI shows before the
      // user presses Build.
      await notifier.loadAll();
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.plans.single.status, 'polling_paramedics');

      // This is the exact call the Build button's onPressed makes.
      final buildFuture = notifier.buildPlan(1);

      // Immediately after invoking buildPlan (before it resolves), the
      // notifier must already be in the loading state — this is what
      // disables/spins the button.
      expect(notifier.state.isLoading, isTrue);

      await buildFuture;

      // The Future returned by buildPlan must always complete (never hang).
      expect(fakeService.buildCallCount, 1);

      // isLoading must be cleared no matter what.
      expect(notifier.state.isLoading, isFalse);

      // The plan list must have been refreshed with the latest status from
      // the (fake) server — not a stale cached "polling_paramedics".
      expect(notifier.state.plans.single.status, 'building');

      // No error should be recorded on the success path.
      expect(notifier.state.error, isNull);
    },
  );

  test(
    'buildPlan clears isLoading even when the service reports failure',
    () async {
      final fakeService = _FakeAdminShiftService();
      final notifier = ShiftManagementNotifier(fakeService);
      await notifier.loadAll();

      // Force the failure branch.
      final failingService = _FailingAdminShiftService();
      final failingNotifier = ShiftManagementNotifier(failingService);
      await failingNotifier.loadAll();

      await failingNotifier.buildPlan(1);

      expect(failingNotifier.state.isLoading, isFalse);
      expect(failingNotifier.state.error, isNotNull);
    },
  );
}

class _FailingAdminShiftService extends AdminShiftService {
  _FailingAdminShiftService() : super(ApiService());

  @override
  Future<List<ShiftPlanModel>> fetchPlans() async => [
        ShiftPlanModel(
          id: 1,
          month: 7,
          year: 2026,
          status: 'polling_paramedics',
          createdAt: DateTime(2026, 7, 1),
        ),
      ];

  @override
  Future<ShiftStatisticsModel> fetchStatistics() async =>
      ShiftStatisticsModel.empty();

  @override
  Future<List<SwapRequestModel>> fetchSwapRequests() async => [];

  @override
  Future<bool> buildPlan(int id) async => false;
}
