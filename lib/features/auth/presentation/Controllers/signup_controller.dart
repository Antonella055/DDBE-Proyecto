import 'package:flutter/material.dart'; 
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/signup_usecase.dart';


class SignUpController with ChangeNotifier {
  final SignUpUseCase signUpUseCase;

  SignUpController(this.signUpUseCase);

  bool _isLoading = false;
  String? _errorMessage;
  UserEntity? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    DateTime? birthDate,
    String? gender,
    String? userType,
  }) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners(); 

    try {
      final user = await signUpUseCase.call(
        email: email,
        password: password,
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
        userType: userType,
      );
      _currentUser = user;
      _errorMessage = null; 
    } on Exception catch (e) {
      _errorMessage = e.toString(); 
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}