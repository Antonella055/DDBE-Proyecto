class PasswordReset {
  final String email;
  final String? token;
  final String? newPassword;

  const PasswordReset({
    required this.email,
    this.token,
    this.newPassword,
  });
}