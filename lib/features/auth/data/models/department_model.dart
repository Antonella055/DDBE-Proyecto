class DepartmentModel {
  final int idDepartment;
  final String dptName;
  final int idFaculty;

  DepartmentModel({
    required this.idDepartment,
    required this.dptName,
    required this.idFaculty,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      idDepartment: json['id_department'] as int,
      dptName: json['dpt_name'] as String,
      idFaculty: json['id_faculty'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_department': idDepartment,
      'dpt_name': dptName,
      'id_faculty': idFaculty,
    };
  }
}