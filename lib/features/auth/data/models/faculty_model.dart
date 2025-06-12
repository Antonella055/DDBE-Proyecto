class FacultyModel {
  final int idFaculty;
  final String name;

  FacultyModel({required this.idFaculty, required this.name});

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      idFaculty: json['id_faculty'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_faculty': idFaculty,
      'name': name,
    };
  }
}