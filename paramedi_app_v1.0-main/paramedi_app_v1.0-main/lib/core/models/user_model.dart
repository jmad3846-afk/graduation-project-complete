class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? rank;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.rank,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      role: json['role'],
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'rank': rank,
    };
  }
}
