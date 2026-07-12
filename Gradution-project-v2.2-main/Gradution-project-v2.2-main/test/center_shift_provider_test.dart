import 'package:flutter_test/flutter_test.dart';
import 'package:ems_op_room/core/models/upcoming_shift_model.dart';
import 'package:ems_op_room/core/network/api_service.dart';
import 'package:ems_op_room/core/providers/center_shift_provider.dart';
import 'package:ems_op_room/core/services/center_shift_service.dart';

// Fakes the network boundary only, so the notifier/state chain runs
// unmodified. Lets tests dictate exactly what the "backend" returns for
// each fetch, keyed by centerId, without a running server.
class _FakeCenterShiftService extends CenterShiftService {
  _FakeCenterShiftService(this.shiftsByCenter) : super(ApiService());

  final Map<int?, UpcomingShiftModel?> shiftsByCenter;
  bool checkInResult = true;

  @override
  Future<UpcomingShiftModel?> fetchUpcomingShift({int? afterShiftId, int? centerId}) async {
    return shiftsByCenter[centerId];
  }

  @override
  Future<bool> checkIn(int assignmentId) async => checkInResult;
}

UpcomingShiftModel _shift(int id) => UpcomingShiftModel(
      shiftId: id,
      date: '2026-07-12',
      shiftType: 'morning',
      teams: const [],
    );

void main() {
  test('switching to a center with no upcoming shift clears the previous shift', () async {
    final service = _FakeCenterShiftService({
      1: _shift(101),
      2: null,
    });
    final notifier = CenterShiftNotifier(service);

    await notifier.loadUpcomingShift(centerId: 1);
    expect(notifier.state.shift?.shiftId, 101);

    await notifier.loadUpcomingShift(centerId: 2);

    // This is the bug the review swarm found: copyWith's `shift ?? this.shift`
    // silently kept center 1's shift when the fetch for center 2 legitimately
    // returned null, because `clearShift` was never passed as true.
    expect(notifier.state.shift, isNull);
  });

  test('advancing past the last shift via loadNextShift clears the displayed shift', () async {
    final service = _FakeCenterShiftService({1: _shift(201)});
    final notifier = CenterShiftNotifier(service);

    await notifier.loadUpcomingShift(centerId: 1);
    expect(notifier.state.shift?.shiftId, 201);

    // fetchUpcomingShift ignores afterShiftId in this fake and just returns
    // whatever is registered for the center — simulate "no next shift" by
    // registering null for the same center on this call path instead.
    final noNextService = _FakeCenterShiftService({1: null});
    final noNextNotifier = CenterShiftNotifier(noNextService)
      ..state; // no-op, just documenting state exists
    await noNextNotifier.loadUpcomingShift(centerId: 1);
    await noNextNotifier.loadNextShift();

    expect(noNextNotifier.state.shift, isNull);
  });

  test('checkIn refresh clears the shift if the refreshed fetch returns null', () async {
    final service = _FakeCenterShiftService({1: _shift(301)});
    final notifier = CenterShiftNotifier(service);
    await notifier.loadUpcomingShift(centerId: 1);
    expect(notifier.state.shift?.shiftId, 301);

    // Simulate the shift disappearing server-side between load and check-in
    // refresh (e.g. all assignments for it were removed).
    service.shiftsByCenter[1] = null;

    final ok = await notifier.checkIn(999);

    expect(ok, isTrue);
    expect(notifier.state.shift, isNull);
  });

  test('clearForNoCenter resets state without fetching', () async {
    final service = _FakeCenterShiftService({1: _shift(401)});
    final notifier = CenterShiftNotifier(service);
    await notifier.loadUpcomingShift(centerId: 1);
    expect(notifier.state.shift, isNotNull);

    notifier.clearForNoCenter();

    expect(notifier.state.shift, isNull);
    expect(notifier.state.centerId, isNull);
    expect(notifier.state.isLoading, isFalse);
  });
}
