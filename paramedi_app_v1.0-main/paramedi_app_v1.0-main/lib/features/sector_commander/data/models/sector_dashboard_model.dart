import 'case_model.dart';
import 'team_model.dart';
import 'center_model.dart';

class SectorDashboardModel {
  final List<CaseModel> activeTasks;
  final List<CaseModel> pendingTasks;
  final List<TeamModel> teams;
  final List<CenterModel> centers;

  SectorDashboardModel({
    required this.activeTasks,
    required this.pendingTasks,
    required this.teams,
    required this.centers,
  });

  factory SectorDashboardModel.fromJson(Map<String, dynamic> json) {
    final active = (json['active_tasks'] as List<dynamic>?) ?? [];
    final pending = (json['pending_tasks'] as List<dynamic>?) ?? [];
    final teams = (json['teams'] as List<dynamic>?) ?? [];
    final centers = (json['centers'] as List<dynamic>?) ?? [];

    return SectorDashboardModel(
      activeTasks: active.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList(),
      pendingTasks: pending.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList(),
      teams: teams.map((e) => TeamModel.fromJson(e as Map<String, dynamic>)).toList(),
      centers: centers.map((e) => CenterModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'active_tasks': activeTasks.map((e) => e.toJson()).toList(),
        'pending_tasks': pendingTasks.map((e) => e.toJson()).toList(),
        'teams': teams.map((e) => e.toJson()).toList(),
        'centers': centers.map((e) => e.toJson()).toList(),
      };
}
