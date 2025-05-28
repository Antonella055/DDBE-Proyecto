import 'package:flutter/material.dart';

class LoginTitle extends StatelessWidget {
  final bool isMobile;

  const LoginTitle({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Iniciar sesión',
      style: TextStyle(
        fontSize: isMobile ? 24 : 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}