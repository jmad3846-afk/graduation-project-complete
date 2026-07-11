class ScheduleAssigneeModel {
  final int userId;
  final String name;

  ScheduleAssigneeModel({required this.userId, required this.name});

  factory ScheduleAssigneeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleAssigneeModel(
      userId: json['user_id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class ScheduleRowModel {
  final int shiftId;
  final String center;
  final String date;
  final String shiftType;
  final int team;
  final ScheduleAssigneeModel? leader;
  final ScheduleAssigneeModel? scout;
  final ScheduleAssigneeModel? paramedic;

  ScheduleRowModel({
    required this.shiftId,
    required this.center,
    required this.date,
    required this.shiftType,
    required this.team,
    this.leader,
    this.scout,
    this.paramedic,
  });

  static ScheduleAssigneeModel? _parseAssignee(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ScheduleAssigneeModel.fromJson(json);
    }
    return null;
  }

  factory ScheduleRowModel.fromJson(Map<String, dynamic> json) {
    return ScheduleRowModel(
      shiftId: json['shift_id'] ?? 0,
      center: json['center']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      shiftType: json['shift_type']?.toString() ?? '',
      team: json['team'] ?? 1,
      leader: _parseAssignee(json['leader']),
      scout: _parseAssignee(json['scout']),
      paramedic: _parseAssignee(json['paramedic']),
    );
  }
}
