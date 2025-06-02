import 'package:ayudantia_software/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  
  Future<void> call({
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    required String userType, 
  }) async {
    try {
      
      await repository.signUpWithEmailAndPassword(
        email,
        password,
        userType, 
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
      );
      
    } on Exception { 
      rethrow;
    }
  }
}