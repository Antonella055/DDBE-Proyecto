import 'package:flutter/material.dart';

class SocialIcons extends StatelessWidget {
  const SocialIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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