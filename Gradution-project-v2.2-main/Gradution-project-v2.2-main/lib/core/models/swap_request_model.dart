class SwapRequestModel {
  final int id;
  final int requesterAssignmentId;
  final int targetAssignmentId;
  final String requesterName;
  final String targetName;
  final String role;
  final String status;
  final DateTime? createdAt;

  SwapRequestModel({
    required this.id,
    required this.requesterAssignmentId,
    required this.targetAssignmentId,
    required this.requesterName,
    required this.targetName,
    required this.role,
    required this.status,
    this.createdAt,
  });

  factory SwapRequestModel.fromJson(Map<String, dynamic> json) {
    return SwapRequestModel(
      id: json['id'] ?? 0,
      requesterAssignmentId: json['requester_assignment_id'] ?? 0,
      targetAssignmentId: json['target_assignment_id'] ?? 0,
      requesterName: json['requester_name'] ?? 'غير معروف',
      targetName: json['target_name'] ?? 'غير معروف',
      role: json['role'] ?? 'غير معروف',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requester_assignment_id': requesterAssignmentId,
        'target_assignment_id': targetAssignmentId,
        'requester_name': requesterName,
        'target_name': targetName,
        'role': role,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
