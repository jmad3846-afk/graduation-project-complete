class TeamModel {
  final String id;
  final String name;
  final String? vehicleCode;
  final String? userName;
  final int active;
  final int available;

  TeamModel({
    required this.id,
    required this.name,
    this.vehicleCode,
    this.userName,
    required this.active,
    required this.available,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      vehicleCode: json['vehicle_code'] as String?,
      userName: json['user_name'] as String?,
      active: (json['active'] is int) ? json['active'] : int.tryParse('${json['active']}') ?? 0,
      available: (json['available'] is int) ? json['available'] : int.tryParse('${json['available']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vehicle_code': vehicleCode,
        'user_name': userName,
        'active': active,
        'available': available,
      };
}
