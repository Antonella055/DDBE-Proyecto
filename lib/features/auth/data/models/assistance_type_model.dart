
class AssistanceTypeModel {
  final int assistanceTypeId;
  final String type;

  AssistanceTypeModel({
    required this.assistanceTypeId,
    required this.type,
  });

  factory AssistanceTypeModel.fromJson(Map<String, dynamic> json) {
    return AssistanceTypeModel(
      assistanceTypeId: json['assistance_type_id'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assistance_type_id': assistanceTypeId,
      'type': type,
    };
  }
}