import 'shift_assignment_model.dart';

class MyScheduleModel {
  final int month;
  final int year;
  final int compensation;
  final int shiftCount;
  final List<ShiftAssignmentModel> assignments;

  MyScheduleModel({
    required this.month,
    required this.year,
    required this.compensation,
    required this.shiftCount,
    required this.assignments,
  });

  factory MyScheduleModel.empty() => MyScheduleModel(
        month: DateTime.now().month,
        year: DateTime.now().year,
        compensation: 0,
        shiftCount: 0,
        assignments: const [],
      );

  factory MyScheduleModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawAssignments = json['assignments'] is List
        ? json['assignments']
        : const [];

    return MyScheduleModel(
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      compensation: json['compensation'] ?? 0,
      shiftCount: json['shift_count'] ?? 0,
      assignments: rawAssignments
          .map((e) => ShiftAssignmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
