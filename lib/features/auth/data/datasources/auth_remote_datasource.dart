import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUpWithEmailAndPassword(String email, String password);
  Future<void> createUserProfile(UserProfileModel userProfile);
  Future<UserProfileModel?> getUserProfile(String userId);
  Future<void> updateFullUserProfile(UserProfileModel userProfile);
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
      await supabaseClient.from('profiles').insert(userProfile.toJsonForInitialSignup());
    } catch (e) {
      throw Exception('Error al guardar el perfil del usuario: $e');
    }
  }

  @override
    Future<UserProfileModel?> getUserProfile(String userId) async {
      try {
        print('DEBUG - getUserProfile: Intentando obtener perfil para ID: $userId');
        final response = await supabaseClient
            .from('profiles')
            .select()
            .eq('ID', userId) 
            .single(); 
        
        print('DEBUG - getUserProfile: Respuesta obtenida: $response'); 
        // ignore: unnecessary_null_comparison
        if (response != null) {
          return UserProfileModel.fromJson(response);
        }
        return null;
      } catch (e) {
       
        print('ERROR - getUserProfile falló para ID $userId: $e'); 
        return null; 
      } finally {
        print('DEBUG - getUserProfile: Finalizado para ID: $userId');
      }
    }
    
      @override
      Future<void> updateFullUserProfile(UserProfileModel userProfile) async {
        try{


        await supabaseClient
          .from('profiles')
          .update(userProfile.toJsonFull()).eq('ID',userProfile.id);

        }catch(e){
          throw Exception('Error al actualizar el perfil del usuairo :$e');
        }
      }
}
