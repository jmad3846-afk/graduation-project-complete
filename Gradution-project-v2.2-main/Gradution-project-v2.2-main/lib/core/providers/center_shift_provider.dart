import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upcoming_shift_model.dart';
import '../services/center_shift_service.dart';
import 'service_providers.dart';

final centerShiftServiceProvider = Provider<CenterShiftService>(
    (ref) => CenterShiftService(ref.read(apiProvider)));

class CenterShiftState {
  final UpcomingShiftModel? shift;
  // The shift id passed as ?after_shift_id= to produce the currently
  // displayed shift (null means "earliest upcoming"). Remembered so that
  // refreshing after a check-in re-fetches the same shift instead of
  // snapping back to the earliest one.
  final int? afterShiftId;
  final bool isLoading;
  final String? error;

  const CenterShiftState({this.shift, this.afterShiftId, this.isLoading = false, this.error});

  CenterShiftState copyWith({
    UpcomingShiftModel? shift,
    int? afterShiftId,
    bool? isLoading,
    String? error,
    bool clearAfterShiftId = false,
    bool clearError = false,
  }) {
    return CenterShiftState(
      shift: shift ?? this.shift,
      afterShiftId: clearAfterShiftId ? null : (afterShiftId ?? this.afterShiftId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CenterShiftNotifier extends StateNotifier<CenterShiftState> {
  final CenterShiftService _service;

  CenterShiftNotifier(this._service) : super(const CenterShiftState());

  Future<void> loadUpcomingShift() async {
    state = state.copyWith(isLoading: true, clearError: true, clearAfterShiftId: true);
    final shift = await _service.fetchUpcomingShift();
    state = state.copyWith(isLoading: false, shift: shift);
  }

  Future<void> loadNextShift() async {
    final currentId = state.shift?.shiftId;
    state = state.copyWith(isLoading: true, clearError: true);
    final shift = await _service.fetchUpcomingShift(afterShiftId: currentId);
    state = state.copyWith(isLoading: false, shift: shift, afterShiftId: currentId);
  }

  Future<bool> checkIn(int assignmentId) async {
    final ok = await _service.checkIn(assignmentId);
    if (ok) {
      // Refresh whichever shift is currently displayed — using the same
      // afterShiftId that produced it — so the view doesn't snap back to
      // the earliest upcoming shift after the manager has advanced.
      final shift = await _service.fetchUpcomingShift(afterShiftId: state.afterShiftId);
      state = state.copyWith(shift: shift);
    } else {
      state = state.copyWith(error: 'فشل تسجيل الدخول للمناوبة');
    }
    return ok;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final centerShiftProvider =
    StateNotifierProvider<CenterShiftNotifier, CenterShiftState>((ref) {
  return CenterShiftNotifier(ref.read(centerShiftServiceProvider));
});
