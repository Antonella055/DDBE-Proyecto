import 'package:flutter/material.dart';
import '/features/auth/presentation/widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24.0),
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  // Título
                  Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Íconos sociales (solo desktop)
                  if (!isMobile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
                          onPressed: () {
                            // TODO: Conectar a la lógica de Google Auth
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  
                  // Campo de email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 64,
                    // validator: InputValidator.validateEmail,
                  ),
                  const SizedBox(height: 15),
                  
                  // Campo de contraseña
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: _togglePasswordVisibility,
                    ),
                    maxLength: 40,
                    // validator: InputValidator.validatePassword,
                  ),
                  const SizedBox(height: 10),
                  
                  // Olvidé contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Conectar a la lógica de restablecer contraseña
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón de ingreso
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _loading = !_loading;
                              });
                              // TODO: Conectar a la lógica de inicio de sesión
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Ingresar'),
                    ),
                  ),
                  
                  // Sección social para móviles
                  if (isMobile)
                    Column(
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}