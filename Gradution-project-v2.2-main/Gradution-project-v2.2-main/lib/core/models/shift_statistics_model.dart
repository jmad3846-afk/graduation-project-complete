class ShiftStatisticsModel {
  final int planId;
  final int totalPolls;
  final int submittedPolls;
  final int totalAssignments;
  final double completionPercentage;

  ShiftStatisticsModel({
    required this.planId,
    required this.totalPolls,
    required this.submittedPolls,
    required this.totalAssignments,
    required this.completionPercentage,
  });

  factory ShiftStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ShiftStatisticsModel(
      planId: json['plan_id'] ?? 0,
      totalPolls: json['total_polls'] ?? 0,
      submittedPolls: json['submitted_polls'] ?? 0,
      totalAssignments: json['total_assignments'] ?? 0,
      completionPercentage: (json['completion_percentage'] ?? 0).toDouble(),
    );
  }

  factory ShiftStatisticsModel.empty() => ShiftStatisticsModel(
        planId: 0,
        totalPolls: 0,
        submittedPolls: 0,
        totalAssignments: 0,
        completionPercentage: 0,
      );
}
