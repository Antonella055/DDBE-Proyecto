import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    String? userType,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(email, password);
      final userProfile = UserProfileModel(
        id: user.id,
        email: user.email!,
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
        userType: userType,
        createdAt: DateTime.now(), 
        updatedAt: DateTime.now(), 
      );

      await remoteDataSource.createUserProfile(userProfile);

     
      return UserEntity(
        id: user.id,
        email: user.email!,
        fullName: fullName, 
        birthDate: birthDate,
        gender: gender,
        userType: userType,
      );
    } catch (e) {
      rethrow; 
    }
  }
}