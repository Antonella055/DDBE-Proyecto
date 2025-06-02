class AuthResponse {
  final String? userId;
  final String? email;
  final String? error;

  AuthResponse({
    this.userId,
    this.email,
    this.error,
  });

  bool get isSuccess => userId != null;
}