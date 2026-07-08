class UserEntity {
  final String id;
  final String username;
  final String email;
  final String role; // 'superadmin', 'dosen', 'mahasiswa'
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.email,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
