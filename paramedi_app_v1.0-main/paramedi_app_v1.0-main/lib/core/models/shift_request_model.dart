class ShiftRequestModel {
  final int id;
  final int? requesterAssignmentId;
  final int? targetAssignmentId;
  final String requesterName;
  final String targetName;
  final String role;
  final String? reason;
  final String status;
  final String? createdAt;

  ShiftRequestModel({
    required this.id,
    this.requesterAssignmentId,
    this.targetAssignmentId,
    required this.requesterName,
    required this.targetName,
    required this.role,
    this.reason,
    required this.status,
    this.createdAt,
  });

  factory ShiftRequestModel.fromJson(Map<String, dynamic> json) {
    return ShiftRequestModel(
      id: json['id'] ?? 0,
      requesterAssignmentId: json['requester_assignment_id'],
      targetAssignmentId: json['target_assignment_id'],
      requesterName: json['requester_name']?.toString() ?? '',
      targetName: json['target_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      reason: json['reason']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}
