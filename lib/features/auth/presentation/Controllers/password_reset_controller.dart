import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordResetController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Envía el correo de recuperación
  Future<String?> sendResetEmail(String email, {bool isWeb = false}) async {
    try {
      final redirectTo = isWeb
          ? 'http://localhost:3000/reset-password' // URL para web
          : 'ayudantia-unimet://reset-password'; // Deep link para móvil

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      return null;
    } on AuthException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error al enviar el correo: ${e.toString()}';
    }
  }

  // Actualiza la contraseña del usuario
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return null;
    } on AuthException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error al actualizar la contraseña: ${e.toString()}';
    }
  }

  // Valida que las contraseñas sean válidas
  String? validatePasswords(String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return 'Ambos campos son requeridos';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}