import 'package:ayudantia_software/core/errors/exceptions.dart';
import 'package:ayudantia_software/features/auth/domain/entities/user_entity.dart';
import 'package:ayudantia_software/features/auth/domain/repositories/auth_repository.dart';
import 'package:ayudantia_software/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  UserEntity _mapUserProfileModelToUserEntity(UserProfileModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      fullName: model.fullName,
      birthDate: model.birthDate,
      gender: model.gender,
      userType: model.userType,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  UserProfileModel _mapUserEntityToUserProfileModel(UserEntity entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      birthDate: entity.birthDate,
      gender: entity.gender,
      userType: entity.userType,
    );
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    try {
      final userProfileModel = await remoteDataSource.getUserProfile(userId);
      if (userProfileModel == null) {
        return null;
      }
      return _mapUserProfileModelToUserEntity(userProfileModel);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity profile) async {
    try {
      final userProfileModel = _mapUserEntityToUserProfileModel(profile);
      await remoteDataSource.updateUserProfile(userProfileModel);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    try {
      return await remoteDataSource.getStudentProfile(userId);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<void> updateStudentProfile(StudentProfileModel studentProfile) async {
    try {
      await remoteDataSource.updateStudentProfile(studentProfile);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(email, password);
      if (user == null) {
        return null;
      }
      final userProfileModel = await remoteDataSource.getUserProfile(user.id);
      if (userProfileModel == null) {
        return UserEntity(id: user.id, email: user.email!);
      }
      return _mapUserProfileModelToUserEntity(userProfileModel);
    } on AuthExceptionCustom {
      rethrow;
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String userType,
    {String? fullName, DateTime? birthDate, String? gender}
  ) async {
    try {
      await remoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
      );
    } on AuthExceptionCustom {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error inesperado en signUp: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on AuthExceptionCustom {
      rethrow;
    } on ServerException {
      rethrow;
    }
  }
}