class ShiftAssigneeModel {
  final int assignmentId;
  final int userId;
  final String name;
  final String status;
  final String? checkedInAt;

  ShiftAssigneeModel({
    required this.assignmentId,
    required this.userId,
    required this.name,
    required this.status,
    this.checkedInAt,
  });

  bool get isDone => status == 'done';

  factory ShiftAssigneeModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssigneeModel(
      assignmentId: json['assignment_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'selected',
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }
}

class ShiftTeamModel {
  final int team;
  final ShiftAssigneeModel? leader;
  final ShiftAssigneeModel? scout;
  final ShiftAssigneeModel? paramedic;

  ShiftTeamModel({
    required this.team,
    this.leader,
    this.scout,
    this.paramedic,
  });

  List<ShiftAssigneeModel> get filledAssignees =>
      [leader, scout, paramedic].whereType<ShiftAssigneeModel>().toList();

  bool get allCheckedIn => filledAssignees.every((a) => a.isDone);

  static ShiftAssigneeModel? _parse(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ShiftAssigneeModel.fromJson(json);
    }
    return null;
  }

  factory ShiftTeamModel.fromJson(Map<String, dynamic> json) {
    return ShiftTeamModel(
      team: json['team'] ?? 1,
      leader: _parse(json['leader']),
      scout: _parse(json['scout']),
      paramedic: _parse(json['paramedic']),
    );
  }
}

class UpcomingShiftModel {
  final int shiftId;
  final String date;
  final String shiftType;
  final List<ShiftTeamModel> teams;

  UpcomingShiftModel({
    required this.shiftId,
    required this.date,
    required this.shiftType,
    required this.teams,
  });

  bool get allCheckedIn => teams.every((t) => t.allCheckedIn);

  factory UpcomingShiftModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawTeams = json['teams'] is List ? json['teams'] : const [];
    return UpcomingShiftModel(
      shiftId: json['shift_id'] ?? 0,
      date: json['date']?.toString() ?? '',
      shiftType: json['shift_type']?.toString() ?? '',
      teams: rawTeams
          .map((e) => ShiftTeamModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
