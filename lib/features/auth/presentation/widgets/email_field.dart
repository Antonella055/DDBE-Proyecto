import 'package:flutter/material.dart';
import '/features/auth/presentation/widgets/custom_text_field.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Correo electrónico',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      maxLength: 64,
      // validator: InputValidator.validateEmail,
    );
  }
}