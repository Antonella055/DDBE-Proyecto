import 'package:flutter/material.dart';
import '/features/auth/presentation/widgets/custom_text_field.dart';
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool passwordVisible;
  final VoidCallback onToggleVisibility;

  const PasswordField({
    super.key,
    required this.controller,
    required this.passwordVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Contraseña',
      prefixIcon: Icons.lock,
      obscureText: !passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: onToggleVisibility,
      ),
      maxLength: 40,
      // validator: InputValidator.validatePassword,
    );
  }
}