import 'package:ayudantia_software/features/auth/domain/entities/user_entity.dart'; 
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';

abstract class AuthRepository {
  Future<UserEntity?> getUserProfile(String userId); 
  Future<void> updateUserProfile(UserEntity profile); 

  Future<StudentProfileModel?> getStudentProfile(String userId);
  Future<void> updateStudentProfile(StudentProfileModel studentProfile);

  Future<UserEntity?> signInWithEmailAndPassword(String email, String password); 
  Future<void> signUpWithEmailAndPassword(String email, String password, String userType, {String? fullName, DateTime? birthDate, String? gender}); // Recibe más datos
  Future<void> signOut();
}