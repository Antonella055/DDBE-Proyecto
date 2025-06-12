class AdminModel {
  final String idAdmin;
  final DateTime? createdDate;
  final bool? isActive;
  final String? role;
  final DateTime? inactiveSince;

  AdminModel({
    required this.idAdmin,
    this.createdDate,
    this.isActive,
    this.role,
    this.inactiveSince,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      idAdmin: json['id_admin'] as String,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      isActive: json['is_active'] as bool?,
      role: json['role'] as String?,
      inactiveSince: json['inactive_since'] != null
          ? DateTime.parse(json['inactive_since'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_admin': idAdmin,
      'created_date': createdDate?.toIso8601String(),
      'is_active': isActive,
      'role': role,
      'inactive_since': inactiveSince?.toIso8601String(),
    };
  }
}