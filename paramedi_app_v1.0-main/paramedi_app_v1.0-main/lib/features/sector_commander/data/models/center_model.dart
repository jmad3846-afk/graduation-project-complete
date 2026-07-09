class CenterModel {
  final int id;
  final String name;
  final int vehiclesCount;
  final int activeCasesCount;
  final int pendingCasesCount;

  CenterModel({
    required this.id,
    required this.name,
    required this.vehiclesCount,
    required this.activeCasesCount,
    required this.pendingCasesCount,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      vehiclesCount: json['vehicles_count'] is int ? json['vehicles_count'] : int.tryParse('${json['vehicles_count']}') ?? 0,
      activeCasesCount: json['active_cases_count'] is int ? json['active_cases_count'] : int.tryParse('${json['active_cases_count']}') ?? 0,
      pendingCasesCount: json['pending_cases_count'] is int ? json['pending_cases_count'] : int.tryParse('${json['pending_cases_count']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vehicles_count': vehiclesCount,
        'active_cases_count': activeCasesCount,
        'pending_cases_count': pendingCasesCount,
      };
}
