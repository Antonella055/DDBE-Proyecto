import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate, 
    String? gender, 
    String? userType, 
    
  });
}