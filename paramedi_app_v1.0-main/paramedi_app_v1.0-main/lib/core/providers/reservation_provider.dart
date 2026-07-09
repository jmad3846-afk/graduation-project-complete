import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_client/pusher_client.dart';

import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import 'service_providers.dart';
import 'auth_provider.dart';

/// Holds the live reservation state for a single shift plan's poll screen,
/// kept in sync via websocket events (ShiftReserved / ShiftReleased / ShiftConfirmed)
/// on top of an initial REST snapshot.
///
/// A slot is identified by (centerId, day, shiftType, rank) — reservations
/// lock an exact center chosen by the user, not just a time/rank.
class ReservationNotifier extends ChangeNotifier {
  final ReservationService _service;
  final int shiftPlanId;
  final int? currentUserId;

  final Map<ReservationSlotKey, ReservationModel> _slots = {};
  final Map<ReservationSlotKey, int> _myReservationIds = {};

  Channel? _channel;
  bool _disposed = false;

  ReservationNotifier(this._service, this.shiftPlanId, this.currentUserId);

  ReservationModel? slotAt(int centerId, int day, String shiftType, String rank) {
    return _slots[ReservationSlotKey(centerId: centerId, day: day, shiftType: shiftType, rank: rank)];
  }

  bool isReserved(int centerId, int day, String shiftType, String rank) {
    return slotAt(centerId, day, shiftType, rank) != null;
  }

  bool isReservedByCurrentUser(int centerId, int day, String shiftType, String rank) {
    final slot = slotAt(centerId, day, shiftType, rank);
    return slot != null && currentUserId != null && slot.userId == currentUserId;
  }

  bool isConfirmed(int centerId, int day, String shiftType, String rank) {
    return slotAt(centerId, day, shiftType, rank)?.status == 'confirmed';
  }

  /// Fetch the current snapshot of reservations for this plan, then subscribe
  /// to the shared websocket channel so future changes (from any user) apply
  /// instantly without a refresh.
  Future<void> load(PusherClient? pusherClient) async {
    final reservations = await _service.currentReservations(shiftPlanId);
    _slots.clear();
    _myReservationIds.clear();
    for (final r in reservations) {
      final key = ReservationSlotKey(centerId: r.centerId, day: r.day, shiftType: r.shiftType, rank: r.rank);
      _slots[key] = r;
      if (currentUserId != null && r.userId == currentUserId) {
        _myReservationIds[key] = r.id;
      }
    }
    _safeNotify();

    _subscribe(pusherClient);
  }

  void _subscribe(PusherClient? pusherClient) {
    if (pusherClient == null) return;
    _channel = pusherClient.subscribe('private-shift-plan.$shiftPlanId');
    _channel!.bind('ShiftReserved', _onReserved);
    _channel!.bind('ShiftReleased', _onReleased);
    _channel!.bind('ShiftConfirmed', _onConfirmed);
  }

  void _onReserved(PusherEvent? event) => _applyEvent(event, 'reserved');
  void _onReleased(PusherEvent? event) => _applyRelease(event);
  void _onConfirmed(PusherEvent? event) => _applyEvent(event, 'confirmed');

  void _applyEvent(PusherEvent? event, String status) {
    final payload = _decode(event);
    if (payload == null) return;

    final key = ReservationSlotKey(
      centerId: _asInt(payload['center_id']),
      day: _asInt(payload['day']),
      shiftType: payload['shift_type'] as String,
      rank: payload['rank'] as String,
    );

    final userId = _asInt(payload['user_id']);

    _slots[key] = ReservationModel(
      id: _slots[key]?.id ?? 0,
      shiftPlanId: shiftPlanId,
      centerId: key.centerId,
      userId: userId,
      day: key.day,
      shiftType: key.shiftType,
      rank: key.rank,
      status: status,
    );

    if (currentUserId != null && userId == currentUserId && _slots[key]!.id != 0) {
      _myReservationIds[key] = _slots[key]!.id;
    }

    _safeNotify();
  }

  void _applyRelease(PusherEvent? event) {
    final payload = _decode(event);
    if (payload == null) return;

    final key = ReservationSlotKey(
      centerId: _asInt(payload['center_id']),
      day: _asInt(payload['day']),
      shiftType: payload['shift_type'] as String,
      rank: payload['rank'] as String,
    );

    _slots.remove(key);
    _myReservationIds.remove(key);
    _safeNotify();
  }

  /// Websocket payloads are decoded from JSON and, depending on the DB driver
  /// serializing the broadcast, numeric fields can arrive as either a JSON
  /// number or a numeric string — coerce defensively instead of `as int`.
  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }

  Map<String, dynamic>? _decode(PusherEvent? event) {
    if (event?.data == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(event!.data!));
    } catch (_) {
      return null;
    }
  }

  /// Reserve a slot. Applies an optimistic local update, then confirms with
  /// the backend; on success it records the reservation id needed for
  /// release/confirm. Throws ReservationConflictException on 409.
  Future<void> reserve(int centerId, int day, String shiftType, String rank) async {
    final key = ReservationSlotKey(centerId: centerId, day: day, shiftType: shiftType, rank: rank);

    _slots[key] = ReservationModel(
      id: 0,
      shiftPlanId: shiftPlanId,
      centerId: centerId,
      userId: currentUserId ?? 0,
      day: day,
      shiftType: shiftType,
      rank: rank,
      status: 'reserved',
    );
    _safeNotify();

    try {
      final reservationId = await _service.reserve(
        shiftPlanId: shiftPlanId,
        centerId: centerId,
        day: day,
        shiftType: shiftType,
        rank: rank,
      );
      _myReservationIds[key] = reservationId;
      _slots[key] = ReservationModel(
        id: reservationId,
        shiftPlanId: shiftPlanId,
        centerId: centerId,
        userId: currentUserId ?? 0,
        day: day,
        shiftType: shiftType,
        rank: rank,
        status: 'reserved',
      );
      _safeNotify();
    } catch (e) {
      // Roll back the optimistic slot; the ShiftReserved broadcast (if the
      // slot really is held by someone else) will re-populate it correctly.
      _slots.remove(key);
      _safeNotify();
      rethrow;
    }
  }

  Future<void> release(int centerId, int day, String shiftType, String rank) async {
    final key = ReservationSlotKey(centerId: centerId, day: day, shiftType: shiftType, rank: rank);
    final reservationId = _myReservationIds[key];
    if (reservationId == null) return;

    final previous = _slots[key];
    _slots.remove(key);
    _myReservationIds.remove(key);
    _safeNotify();

    try {
      await _service.release(shiftPlanId: shiftPlanId, reservationId: reservationId);
    } catch (e) {
      if (previous != null) {
        _slots[key] = previous;
        _myReservationIds[key] = reservationId;
        _safeNotify();
      }
      rethrow;
    }
  }

  /// Confirm every reservation the current user is still holding for this plan.
  Future<void> confirmAll() async {
    for (final entry in Map<ReservationSlotKey, int>.from(_myReservationIds).entries) {
      await _service.confirm(shiftPlanId: shiftPlanId, reservationId: entry.value);
      final existing = _slots[entry.key];
      if (existing != null) {
        _slots[entry.key] = ReservationModel(
          id: existing.id,
          shiftPlanId: existing.shiftPlanId,
          centerId: existing.centerId,
          userId: existing.userId,
          day: existing.day,
          shiftType: existing.shiftType,
          rank: existing.rank,
          status: 'confirmed',
        );
      }
    }
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_channel != null) {
      _channel!.unbind('ShiftReserved');
      _channel!.unbind('ShiftReleased');
      _channel!.unbind('ShiftConfirmed');
    }
    super.dispose();
  }
}

/// Family provider keyed by shiftPlanId so each poll screen gets its own
/// live reservation state, scoped to the plan shared by every participant.
final reservationProvider = ChangeNotifierProvider.family<ReservationNotifier, int>((ref, shiftPlanId) {
  final service = ref.read(reservationServiceProvider);
  final userId = ref.read(authNotifierProvider).user?.id;
  return ReservationNotifier(service, shiftPlanId, userId);
});
