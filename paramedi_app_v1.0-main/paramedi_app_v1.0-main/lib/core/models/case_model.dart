class CaseModel {
  final int id;
  final String status;
  final String type;
  final String severity;
  final double latitude;
  final double longitude;

  CaseModel({
    required this.id,
    required this.status,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'type': type,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
