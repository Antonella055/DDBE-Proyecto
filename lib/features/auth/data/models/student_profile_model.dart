class StudentProfileModel {
  final String id;
  final String? carnet;
  final int? careerId;
  final int? assistanceTypeId;
  final DateTime? admissionTrimester;
  final String? avatarUrl;

  StudentProfileModel({
    required this.id,
    this.carnet,
    this.careerId,
    this.assistanceTypeId,
    this.admissionTrimester,
    this.avatarUrl,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['ID'] as String,
      carnet: json['carnet'] as String?,
      careerId: (json['career_id'] as num?)?.toInt(),
      assistanceTypeId: (json['assistance_type_id'] as num?)?.toInt(),
      admissionTrimester: json['admission_trimester'] != null
          ? DateTime.parse(json['admission_trimester'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      if (carnet != null) 'carnet': carnet,
      if (careerId != null) 'career_id': careerId,
      if (assistanceTypeId != null) 'assistance_type_id': assistanceTypeId,
      if (admissionTrimester != null) 'admission_trimester': admissionTrimester!.toIso8601String().split('T').first,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  StudentProfileModel copyWith({
    String? id,
    String? carnet,
    int? careerId,
    int? assistanceTypeId,
    DateTime? admissionTrimester,
    String? avatarUrl,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      carnet: carnet ?? this.carnet,
      careerId: careerId ?? this.careerId,
      assistanceTypeId: assistanceTypeId ?? this.assistanceTypeId,
      admissionTrimester: admissionTrimester ?? this.admissionTrimester,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}