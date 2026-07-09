class ReservationModel {
  final int id;
  final int shiftPlanId;
  final int centerId;
  final int userId;
  final int day;
  final String shiftType;
  final String rank;
  final String status;

  ReservationModel({
    required this.id,
    required this.shiftPlanId,
    required this.centerId,
    required this.userId,
    required this.day,
    required this.shiftType,
    required this.rank,
    required this.status,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: _asInt(json['id']),
      shiftPlanId: _asInt(json['shift_plan_id']),
      centerId: _asInt(json['center_id']),
      userId: _asInt(json['user_id']),
      day: _asInt(json['day']),
      shiftType: json['shift_type'] ?? '',
      rank: json['rank'] ?? '',
      status: json['status'] ?? 'reserved',
    );
  }

  /// The raw reservations endpoint serializes model attributes directly, so
  /// numeric fields can arrive as a JSON number or a numeric string
  /// depending on the DB driver — coerce defensively instead of assuming int.
  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Identifies a reservation slot regardless of who holds it. Reservations
/// now lock an exact center, not just a time/rank, so centerId is part of
/// the slot's identity — a required field so any call site that forgets to
/// pass it fails at compile time rather than silently matching the wrong slot.
class ReservationSlotKey {
  final int centerId;
  final int day;
  final String shiftType;
  final String rank;

  const ReservationSlotKey({
    required this.centerId,
    required this.day,
    required this.shiftType,
    required this.rank,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationSlotKey &&
          centerId == other.centerId &&
          day == other.day &&
          shiftType == other.shiftType &&
          rank == other.rank;

  @override
  int get hashCode => Object.hash(centerId, day, shiftType, rank);
}
