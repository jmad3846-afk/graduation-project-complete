class VehicleModel {
  final int id;
  final String code;
  final String status;
  final int? centerId;
  final double latitude;
  final double longitude;

  VehicleModel({
    required this.id,
    required this.code,
    required this.status,
    required this.centerId,
    required this.latitude,
    required this.longitude,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      status: json['status'] ?? '',
      centerId: json['center_id'] as int?,
      latitude: (json['current_lat'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['current_lng'] ?? json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'status': status,
      'center_id': centerId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
