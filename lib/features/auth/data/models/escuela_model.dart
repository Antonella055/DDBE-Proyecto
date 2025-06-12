class EscuelaModel {
  final int idEscuela;
  final String escuelaName;
  final int idFaculty;

  EscuelaModel({
    required this.idEscuela,
    required this.escuelaName,
    required this.idFaculty,
  });

  factory EscuelaModel.fromJson(Map<String, dynamic> json) {
    return EscuelaModel(
      idEscuela: json['id_escuela'] as int,
      escuelaName: json['escuela_name'] as String,
      idFaculty: json['id_faculty'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_escuela': idEscuela,
      'escuela_name': escuelaName,
      'id_faculty': idFaculty,
    };
  }
}