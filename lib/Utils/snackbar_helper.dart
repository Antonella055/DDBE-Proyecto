import 'package:flutter/material.dart';



void showSnackBar(BuildContext context, String message, {bool isError = false}) {

  if (!context.mounted) {
    return;
  }

  // Oculta cualquier SnackBar que se esté mostrando actualmente para evitar solapamientos.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Muestra el nuevo SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3), // Duración por defecto de 3 segundos
      behavior: SnackBarBehavior.floating, // Opcional: para que flote sobre el contenido
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Opcional: bordes redondeados
      margin: const EdgeInsets.all(16), // Opcional: margen desde los bordes
    ),
  );
}