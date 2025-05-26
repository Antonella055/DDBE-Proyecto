import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon; // Hacemos el icono opcional
  final bool obscureText;
  final Widget? suffixIcon; // Permitimos un icono al final (ej. para visibilidad de contraseña)
  final String? Function(String?)? validator; // Para la validación del formulario
  final TextInputType? keyboardType; // Tipo de teclado para el input
  final int? maxLength; // Longitud máxima del texto

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false, // Por defecto no es oculto
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField( // Usamos TextFormField para integrar con Form y validadores
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null, // Mostrar icono si existe
          suffixIcon: suffixIcon, // Mostrar icono al final si existe
          filled: true,
          fillColor: Colors.grey[200],
          counterText: "", // Oculta el contador de caracteres si usas maxLength
        ),
      ),
    );
  }
}