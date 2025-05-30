import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUpWithEmailAndPassword(String email, String password);
  Future<void> createUserProfile(UserProfileModel userProfile);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final AuthResponse response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('No se pudo obtener la información del usuario después del registro.');
      }
      return response.user!;
    } on AuthException catch (e) {
      if (e.message.contains('duplicate key value violates')) {
        throw Exception('El correo electrónico ya está registrado.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> createUserProfile(UserProfileModel userProfile) async {
    try {
      // Use the specific toJson method for initial signup data
      await supabaseClient.from('profiles').insert(userProfile.toJsonForInitialSignup());
    } catch (e) {
      throw Exception('Error al guardar el perfil del usuario: $e');
    }
  }

  // Example of a method for full profile update
  // Future<void> updateFullUserProfile(UserProfileModel userProfile) async {
  //   try {
  //     await supabaseClient.from('profiles').update(userProfile.toJsonFull()).eq('id_usuario', userProfile.id);
  //   } catch (e) {
  //     throw Exception('Error al actualizar el perfil del usuario: $e');
  //   }
  // }
}