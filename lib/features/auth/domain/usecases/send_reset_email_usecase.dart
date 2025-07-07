import 'package:ayudantia_software/core/errors/exceptions.dart';
import 'package:ayudantia_software/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<void> call(String email) async {
    try {
      await repository.sendPasswordResetEmail(email);
    } on AuthExceptionCustom {
      rethrow; // Relanza excepciones específicas
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error inesperado al enviar correo de recuperación');
    }
  }
}