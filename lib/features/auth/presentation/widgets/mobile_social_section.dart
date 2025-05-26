import 'package:flutter/material.dart';

class MobileSocialSection extends StatelessWidget {
  const MobileSocialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text('O inicia sesión con'),
        const SizedBox(height: 10),
        IconButton(
          icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
          onPressed: () {
            // TODO: Conectar a la lógica de Google Auth
          },
        ),
      ],
    );
  }
}