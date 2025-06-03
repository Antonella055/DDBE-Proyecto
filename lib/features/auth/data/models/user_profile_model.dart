class UserProfileModel {
  final String id;
  final String email;
  final String? fullName; 
  final DateTime? birthDate; 
  final DateTime? createdAt; 
  final DateTime? updatedAt; 
  final String? gender; 
  final String? userType; 


  UserProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.gender,
    this.userType,
  });

  Map<String, dynamic> toJsonForInitialSignup() {
    return {
      'ID': id, 
      'email': email,
    };
  }

  
 
  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (userType != null) 'user_type': userType,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['ID'], 
      email: json['email'],
      fullName: json['full_name'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      gender: json['gender'] as String?,
      userType: (json['user_type'] as String?), 
    );
  }
}