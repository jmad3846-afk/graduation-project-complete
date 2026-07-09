class CaseModel {
  final int id;
  final String status;
  final String triageCode;
  final Map<String, dynamic>? center;
  final Map<String, dynamic>? vehicle;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? caller;
  final double? latitude;
  final double? longitude;
  final String? destinationHospital;
  final String? trackingToken;
  final String createdAt;
  final String updatedAt;

  CaseModel({
    required this.id,
    required this.status,
    required this.triageCode,
    this.center,
    this.vehicle,
    this.patient,
    this.caller,
    this.latitude,
    this.longitude,
    this.destinationHospital,
    this.trackingToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] as int,
      status: json['status'] as String,
      triageCode: json['triage_code'] as String,
      center: json['center'] as Map<String, dynamic>?,
      vehicle: json['vehicle'] as Map<String, dynamic>?,
      patient: json['patient'] as Map<String, dynamic>?,
      caller: json['caller'] as Map<String, dynamic>?,
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : null,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : null,
      destinationHospital: json['destination_hospital'] as String?,
      trackingToken: json['tracking_token'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'triage_code': triageCode,
        'center': center,
        'vehicle': vehicle,
        'patient': patient,
        'caller': caller,
        'latitude': latitude,
        'longitude': longitude,
        'destination_hospital': destinationHospital,
        'tracking_token': trackingToken,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
