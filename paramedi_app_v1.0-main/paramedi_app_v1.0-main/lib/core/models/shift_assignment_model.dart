class ShiftAssignmentModel {
  final int id;
  final String date;
  final String shiftType;
  final String center;
  final String role;
  final int? teamNumber;
  final int? vehicleId;

  ShiftAssignmentModel({
    required this.id,
    required this.date,
    required this.shiftType,
    required this.center,
    required this.role,
    this.teamNumber,
    this.vehicleId,
  });

  factory ShiftAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentModel(
      id: json['id'] ?? 0,
      date: json['date']?.toString() ?? '',
      shiftType: json['shift_type']?.toString() ?? json['type']?.toString() ?? '',
      center: json['center']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      teamNumber: json['team_number'],
      vehicleId: json['vehicle_id'],
    );
  }
}

class SwapCandidateModel {
  final int id;
  final int userId;
  final String userName;
  final String date;
  final String shiftType;
  final String center;
  final String role;

  SwapCandidateModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.shiftType,
    required this.center,
    required this.role,
  });

  factory SwapCandidateModel.fromJson(Map<String, dynamic> json) {
    return SwapCandidateModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? 'Unknown',
      date: json['date']?.toString() ?? '',
      shiftType: json['shift_type']?.toString() ?? '',
      center: json['center']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}
