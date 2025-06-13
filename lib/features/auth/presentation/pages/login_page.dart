import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/profile_page.dart';
import '/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ayudantia_software/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _loading = false;
  bool _redirecting = false;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    // Si hay ?code=... en la URL, muestra el modal de cambio de contraseña
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            child: SizedBox(
              width: 400,
              child: ResetPasswordPage(code: code),
            ),
          ),
        );
      });
    }

    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (session != null) {
          _redirecting = true;
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        }
      },
      onError: (error) {
        if (!mounted) return;
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Ocurrió un error inesperado', isError: true);
        }
      },
    );
  }

  Future<void> _resetPasswordRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      context.showSnackBar("Por favor, ingresa tu correo electrónico.", isError: true);
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) {
        context.showSnackBar(
          "Se ha enviado un correo para restablecer tu contraseña. Abre el enlace en la MISMA pestaña donde solicitaste el reseteo.",
        );
      }
    } on AuthException catch (e) {
      context.showSnackBar(e.message, isError: true);
    } catch (e) {
      context.showSnackBar("Error al enviar el correo: $e", isError: true);
    }
  }

  void _showResetPasswordEmailModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Recuperar contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _resetPasswordRequest,
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      context.showSnackBar("Por favor, completa todos los campos.", isError: true);
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null) {
        context.showSnackBar("No se pudo iniciar sesión. Verifica tus credenciales.", isError: true);
      }
    } on AuthException catch (e) {
      context.showSnackBar(e.message, isError: true);
    } catch (e) {
      context.showSnackBar("Error al iniciar sesión: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(24.0),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 500,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D6).withOpacity(0.64),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 45,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF8200),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!isMobile)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.google,
                                color: Color(0xFFEA4335),
                                size: 32,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Correo electrónico',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 64,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Contraseña',
                        prefixIcon: Icons.lock,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
                        ),
                        maxLength: 40,
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: isMobile ? double.infinity : null,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: const Color(0xFFFF8200),
                            foregroundColor: Colors.white,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Ingresar'),
                        ),
                      ),
                      if (isMobile)
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text('O inicia sesión con'),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.google,
                                color: Color(0xFFEA4335),
                                size: 32,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}