import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call({ 
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    String? userType,
  }) async {
    try {
      final user = await repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
        userType: userType,
      );
      return user; 
    } on Exception {
      rethrow; 
    }
  }
}