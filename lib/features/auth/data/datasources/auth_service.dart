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
}