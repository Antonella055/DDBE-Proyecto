import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Conectar a la lógica de restablecer contraseña
        },
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
    );
  }
}