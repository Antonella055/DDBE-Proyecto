import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (response.user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Correo o contraseña incorrectos.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResetPasswordEmailModal() {
    showDialog(
      context: context,
      builder: (context) {
        final _resetEmailController = TextEditingController();
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                    _resetEmailController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Correo de restablecimiento enviado.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    const String backgroundUrl = 'https://lbxkcilriktsmfiruvfj.supabase.co/storage/v1/object/public/backgrounds/backgrounds/loginpage_background.jpg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            backgroundUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey,
              child: const Center(child: Icon(Icons.broken_image, size: 60)),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          // Botón de volver en la esquina superior izquierda
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF003087), size: 32),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              tooltip: 'Volver',
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(24.0),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75), 
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color.fromARGB(154, 0, 47, 135), 
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Iniciar sesión',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFFF8000),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.g_mobiledata, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 64,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                        borderSide: BorderSide(color: Color(0xFF003087)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                        borderSide: BorderSide(color: Color(0xFFFF8000), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                        borderSide: BorderSide(color: Color(0xFF003087)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)), // <-- Circular
                        borderSide: BorderSide(color: Color(0xFFFF8000), width: 2),
                      ),
                    ),
                  ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetPasswordEmailModal,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF003087),
                        ),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Ingresar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}