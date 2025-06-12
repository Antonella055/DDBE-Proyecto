import 'package:ayudantia_software/features/auth/data/models/assistance_type_model.dart';
import 'package:ayudantia_software/features/auth/data/models/professor_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/core/errors/exceptions.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/career_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserProfileModel?> getUserProfile(String userId);
  Future<void> createUserProfile(UserProfileModel profile);
  Future<void> updateUserProfile(UserProfileModel profile);

  Future<ProfessorProfileModel?> getProfessorProfile(String userId);
  Future<void> createProfessorProfile(ProfessorProfileModel profile);
  Future<void> updateProfessorProfile(ProfessorProfileModel profile);

  Future<StudentProfileModel?> getStudentProfile(String userId);
  Future<void> createStudentProfile(StudentProfileModel studentProfile);
  Future<void> updateStudentProfile(StudentProfileModel studentProfile);

  Future<List<CareerModel>> getCareers({int? facultyId});
  Future<List<AssistanceTypeModel>> getAssistanceTypes();

  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> createUserProfile(UserProfileModel profile) async {
    try {
      await supabaseClient
          .from('profiles')
          .insert(profile.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear perfil de usuario: $e');
    }
  }

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final data = await supabaseClient
          .from('profiles')
          .select()
          .eq('ID', userId)
          .single();

      return UserProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener perfil: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfileModel userProfile) async {
    try {
      await supabaseClient
          .from('profiles')
          .update(userProfile.toJson()) 
          .eq('ID', userProfile.id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el perfil del usuario: $e');
    }
  }

  @override
  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    try {
      final data = await supabaseClient
          .from('students')
          .select()
          .eq('ID', userId)
          .single();

      return StudentProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw ServerException(message: 'Error inesperado al obtener perfil de estudiante: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener perfil de estudiante: $e');
    }
  }

  @override
  Future<void> createStudentProfile(StudentProfileModel profile) async {
    try {
      await supabaseClient
          .from('students')
          .insert(profile.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear el perfil de estudiante: $e');
    }
  }

  @override
  Future<void> updateStudentProfile(StudentProfileModel profile) async {
    try {
      await supabaseClient
          .from('students')
          .update(profile.toJson())
          .eq('ID', profile.id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el perfil de estudiante: $e');
    }
  }

  @override
  Future<List<CareerModel>> getCareers({int? facultyId}) async {
    try {
      var query = supabaseClient
          .from('careers')
          .select('career_id, name, id_faculty');

      if (facultyId != null) {
        query = query.eq('id_faculty', facultyId);
      }

      final List<dynamic> data = await query;
      return data.map((json) => CareerModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al obtener carreras: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener carreras: $e');
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final AuthResponse response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthExceptionCustom(message: 'Credenciales inválidas');
      }
      return response.user;
    } on AuthException catch (e) {
      throw AuthExceptionCustom(message: e.message);
    } catch (e) {
      throw AuthExceptionCustom(message: 'Error de autenticación inesperado: $e');
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final AuthResponse response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthExceptionCustom(message: 'Fallo el registro del usuario');
      }

      final userId = response.user!.id;
      final userEmail = response.user!.email!;

      String determinedUserType = 'Other';
      if (userEmail.endsWith('@correo.unimet.edu.ve')) {
        determinedUserType = 'Student';
      } else if (userEmail.endsWith('@unimet.edu.ve')) {
        determinedUserType = 'Professor';
      }

      final userProfile = UserProfileModel(
        id: userId,
        email: userEmail,
        fullName: null,
        birthDate: null,
        gender: null,
        userType: determinedUserType,
      );
      await createUserProfile(userProfile);

      if (determinedUserType == 'Student') {
        final studentProfile = StudentProfileModel(id: userId);
        await createStudentProfile(studentProfile);
      }
      
      return response.user;
    } on AuthException catch (e) {
      throw AuthExceptionCustom(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error de base de datos durante el registro: ${e.message}');
    } catch (e) {
      throw AuthExceptionCustom(message: 'Error de registro inesperado: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthExceptionCustom(message: e.message);
    } catch (e) {
      throw AuthExceptionCustom(message: 'Error al cerrar sesión: $e');
    }
  }
  
  @override
  Future<List<AssistanceTypeModel>> getAssistanceTypes() async {
    try {
      final List<dynamic> data = await supabaseClient
          .from('assistance_types') 
          .select('assistance_type_id, type');
      return data.map((json) => AssistanceTypeModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al obtener tipos de asistencia: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener tipos de asistencia: $e');
    }
  }
  
  @override
  Future<void> createProfessorProfile(ProfessorProfileModel profile) async {
    try {
      await supabaseClient
          .from('professors')
          .insert(profile.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear el perfil de profesor: $e');
    }
  }
  
  @override
  Future<ProfessorProfileModel?> getProfessorProfile(String userId) async {
    try {
      final data = await supabaseClient
          .from('professors')
          .select()
          .eq('ID', userId)
          .single();

      return ProfessorProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw ServerException(message: 'Error inesperado al obtener perfil de profesor: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener perfil de profesor: $e');
    }
  }
  
  @override
  Future<void> updateProfessorProfile(ProfessorProfileModel profile) async {
    try {
      await supabaseClient
          .from('professors')
          .update(profile.toJson())
          .eq('ID', profile.id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el perfil de profesor: $e');
    }
  }
}