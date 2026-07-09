class VehicleModel {
  final int id;
  final String status;
  final double latitude;
  final double longitude;

  VehicleModel({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
