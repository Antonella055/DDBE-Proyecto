class CareerModel {
  final int careerId;
  final String name;
  final int? idFaculty;

  CareerModel({required this.careerId, required this.name, this.idFaculty});

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      careerId: json['career_id'] as int,
      name: json['name'] as String,
      idFaculty: json['id_faculty'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'career_id': careerId,
      'name': name,
      'id_faculty': idFaculty,
    };
  }
}