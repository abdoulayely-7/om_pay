class UserResource {
  final String id;
  final String name;
  final String email;
  final String telephone;
  final String role;
  final String? createdAt;
  final String? updatedAt;

  UserResource({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserResource.fromJson(Map<String, dynamic> json) {
    return UserResource(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      telephone: json["telephone"],
      role: json["role"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}
