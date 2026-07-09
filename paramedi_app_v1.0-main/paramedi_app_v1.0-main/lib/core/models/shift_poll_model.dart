class ShiftSelection {
  final int day;
  final String shift;

  ShiftSelection({required this.day, required this.shift});

  factory ShiftSelection.fromJson(Map<String, dynamic> json) {
    return ShiftSelection(
      day: json['day'] is int ? json['day'] : int.tryParse(json['day'].toString()) ?? 1,
      shift: json['shift']?.toString() ?? 'morning',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'shift': shift,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftSelection &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          shift == other.shift;

  @override
  int get hashCode => day.hashCode ^ shift.hashCode;
}

class ShiftPollModel {
  final int id;
  final int? planId;
  final String role;
  final String status;
  final List<ShiftSelection> preferredShifts;
  final List<ShiftSelection> unavailableShifts;
  final String? submittedAt;

  ShiftPollModel({
    required this.id,
    this.planId,
    required this.role,
    required this.status,
    required this.preferredShifts,
    required this.unavailableShifts,
    this.submittedAt,
  });

  factory ShiftPollModel.fromJson(Map<String, dynamic> json) {
    return ShiftPollModel(
      id: json['id'] ?? 0,
      planId: json['plan_id'],
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      preferredShifts: (json['preferred_shifts'] as List?)
              ?.map((e) => ShiftSelection.fromJson(e))
              .toList() ??
          const [],
      unavailableShifts: (json['unavailable_shifts'] as List?)
              ?.map((e) => ShiftSelection.fromJson(e))
              .toList() ??
          const [],
      submittedAt: json['submitted_at']?.toString(),
    );
  }
}
