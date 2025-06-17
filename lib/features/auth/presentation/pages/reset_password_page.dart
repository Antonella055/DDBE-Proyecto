import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? code;
  const ResetPasswordPage({Key? key, this.code}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _code;

  @override
  void initState() {
    super.initState();
    // Si no se pasó el code como argumento, intenta leerlo de la URL (Flutter web)
    _code = widget.code;
    if (_code == null || _code!.isEmpty) {
      final uri = Uri.base;
      final codeFromUrl = uri.queryParameters['code'];
      if (codeFromUrl != null && codeFromUrl.isNotEmpty) {
        _code = codeFromUrl;
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_code == null || _code!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el código de recuperación.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // 1. Intercambia el code por una sesión
      await Supabase.instance.client.auth.exchangeCodeForSession(_code!);

      // 2. Ahora puedes actualizar la contraseña
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada con éxito')),
        );
        Navigator.of(context).pop(); // Cierra el modal/dialog
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Restablecer contraseña',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _updatePassword,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Actualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}