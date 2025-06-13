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
      createdDate: json['created_date'] != null ? DateTime.parse(json['created_date']) : null,
      isActive: json['is_active'] as bool?,
      role: json['role'] as String?,
      inactiveSince: json['inactiveSince'] != null ? DateTime.parse(json['inactiveSince']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'id_admin': idAdmin};
    if (createdDate != null) map['created_date'] = createdDate!.toIso8601String();
    if (isActive != null) map['is_active'] = isActive;
    if (role != null) map['role'] = role;
    if (inactiveSince != null) map['inactiveSince'] = inactiveSince!.toIso8601String();
    return map;
  }
}