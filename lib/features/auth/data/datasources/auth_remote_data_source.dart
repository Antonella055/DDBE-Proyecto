import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; 

abstract class AuthRemoteDataSource {
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final String? url = kIsWeb
          ? null
          : 'io.supabase.flutterquickstart://login-callback/';

      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: url,
        // scopes: ['email'], // <--- REMOVE THIS LINE
        queryParams: {'hd': 'correo.unimet.edu.ve'}
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during Google sign in.');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during password reset.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out.');
    }
  }
}