import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Sign in con email y contrasena
  Future<AuthResponse> signInWithEmailPassword(String email, String password)async{
    return await _supabase.auth.signInWithPassword(
      email:email,
      password:password,
    );
    
  }
  //Sign in con google

  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //get user email
  String? getCurrentUserEmail(){
    final session= _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
   Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
  
   Future<void> sendMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'tu-app://reset-password', // Configura esto en Supabase
    );
  }

  // 2. Restablecer contraseña directamente (requiere configuración especial)
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Esto requiere habilitar "Password Recovery" en Supabase
    // To update the password, use updateUser with the new password after verifying the user
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

 

  
}