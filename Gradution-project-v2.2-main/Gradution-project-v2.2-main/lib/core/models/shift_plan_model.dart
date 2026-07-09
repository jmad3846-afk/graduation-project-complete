class ShiftPlanModel {
  final int id;
  final int month; // 1-12
  final int year;
  final String status;
  final DateTime createdAt;

  ShiftPlanModel({
    required this.id,
    required this.month,
    required this.year,
    required this.status,
    required this.createdAt,
  });

  factory ShiftPlanModel.fromJson(Map<String, dynamic> json) {
    return ShiftPlanModel(
      id: json['id'] ?? 0,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'year': year,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
