class ProfessorProfileModel {
  final String id;
  final int? departamentId;
  final int? escuelaId;
  final int? facultyId;
  final DateTime? hireDate;
  final bool? isActive;

  ProfessorProfileModel({
    required this.id,
    this.departamentId,
    this.escuelaId,
    this.facultyId,
    this.hireDate,
    this.isActive,
  });

  factory ProfessorProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessorProfileModel(
      id: json['ID'] as String,
      departamentId: json['id_departament'] as int?,
      escuelaId: json['id_escuela'] as int?,
      facultyId: json['id_faculty'] as int?,
      hireDate: json['hire_date'] != null ? DateTime.parse(json['hire_date']) : null,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'ID': id};
    if (departamentId != null) map['id_departament'] = departamentId;
    if (escuelaId != null) map['id_escuela'] = escuelaId;
    if (facultyId != null) map['id_faculty'] = facultyId;
    if (hireDate != null) map['hire_date'] = hireDate!.toIso8601String();
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
  
  
}