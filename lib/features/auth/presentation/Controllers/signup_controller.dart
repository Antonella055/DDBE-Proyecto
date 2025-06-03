import 'package:ayudantia_software/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';

class SignUpController with ChangeNotifier {
  final SignUpUseCase signUpUseCase;

  SignUpController(this.signUpUseCase);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await signUpUseCase.call(
        email: email,
        password: password,
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
        userType: userType,
      );

      _errorMessage = null;

    } on AuthExceptionCustom catch (e) {
      _errorMessage = e.message;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error inesperado durante el registro: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}