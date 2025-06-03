class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final DateTime? birthDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? gender;
  final String? userType;

  UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.gender,
    this.userType,
  });
}