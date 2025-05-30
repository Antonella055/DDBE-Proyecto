import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:ayudantia_software/features/auth/presentation/pages/profile_page.dart';

import '/features/auth/presentation/widgets/custom_text_field.dart';

import 'package:ayudantia_software/main.dart';


import 'package:ayudantia_software/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';

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

  // Instancia del DataSource para operaciones de perfil.
  // La inicializamos en initState.
  late final AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();
    
    _authDataSource = AuthRemoteDataSourceImpl(supabase);

   
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
        // Manejo de errores de autenticación
        if (!mounted) return;
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Ocurrió un error inesperado', isError: true);
        }
      },
    );
  }

  // Método para manejar el inicio de sesión del usuario
  Future<void> _login() async {
    // Validar que los campos de correo y contraseña no estén vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      context.showSnackBar("Por favor, ingresa tu correo y contraseña.", isError: true);
      return;
    }

    setState(() {
      _loading = true; // Mostrar indicador de carga
    });

    try {
      // Intenta iniciar sesión con correo y contraseña
      print('DEBUG: Attempting to sign in with email: ${_emailController.text}');
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = response.user; // Obtener el objeto de usuario autenticado

      if (user != null) {
        print('DEBUG: User successfully logged in: ${user.id}, Email: ${user.email}');

        // --- Lógica para verificar y crear el perfil del usuario en la tabla 'profiles' ---
        try {
          print('DEBUG: Checking if profile exists for user ID: ${user.id}');
          // Consultar la tabla 'profiles' para ver si ya existe un perfil para este ID de usuario
          final List<dynamic> profiles = await supabase
              .from('profiles')
              .select()
              .eq('ID', user.id) // Usar 'ID' como nombre de columna
              .limit(1);

          if (profiles.isEmpty) {
            // Si no se encuentra un perfil, se crea uno nuevo.
            print('DEBUG: Profile not found, attempting to create new profile.');
            final UserProfileModel newProfile = UserProfileModel(
              id: user.id,
              email: user.email!, // Asegúrate de que el email no sea nulo aquí
            );
            // Usar el AuthRemoteDataSource para crear el perfil en la BD
            await _authDataSource.createUserProfile(newProfile);
            if (mounted) {
              context.showSnackBar('Perfil creado exitosamente al iniciar sesión.');
            }
            print('DEBUG: Profile creation successful.');
          } else {
            print('DEBUG: Profile already exists for user ID: ${user.id}.');
          }
        } catch (e) {
          // Manejo de errores durante la verificación/creación del perfil
          print('ERROR: Error during profile check/creation: $e');
          if (mounted) {
            context.showSnackBar('Error al verificar/crear el perfil: $e', isError: true);
          }
        }

        // Navegar a la ProfilePage solo si el login y la verificación/creación del perfil fueron exitosos
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      } else {
        // En caso de que el inicio de sesión sea exitoso pero el objeto de usuario sea nulo (inesperado)
        print('DEBUG: Login successful, but user object is null. This is unexpected.');
        if (mounted) {
          context.showSnackBar("Error desconocido al obtener el usuario después del inicio de sesión.", isError: true);
        }
      }

    } on AuthException catch (error) {
      // Capturar y mostrar errores específicos de autenticación de Supabase
      print('ERROR: AuthException during login: ${error.message}');
      context.showSnackBar(error.message, isError: true);
    } catch (e) {
      // Capturar cualquier otro error inesperado
      print('ERROR: General error during login: $e');
      context.showSnackBar("Error al iniciar sesión: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false; // Ocultar indicador de carga
        });
      }
    }
  }

  // Método para alternar la visibilidad de la contraseña
  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel(); // Cancelar la suscripción para evitar fugas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si la pantalla es móvil (menos de 600px de ancho)
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24.0),
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500, // Ancho máximo para no-móviles
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
                  Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botones de inicio de sesión social (solo visibles en no-móviles)
                  if (!isMobile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.g_mobiledata,
                              size: 40, color: Colors.red),
                          onPressed: () {}, // Lógica para Google Sign-in
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // Campo de texto para el correo electrónico
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 64,
                  ),
                  const SizedBox(height: 15),
                  // Campo de texto para la contraseña
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
                  // Botón "¿Olvidaste tu contraseña?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Lógica para restablecer contraseña
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de inicio de sesión
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login, // Deshabilitar si está cargando
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white) // Indicador de carga
                          : const Text('Ingresar'),
                    ),
                  ),
                  // Opciones de inicio de sesión social (solo visibles en móviles)
                  if (isMobile)
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        const Text('O inicia sesión con'),
                        const SizedBox(height: 10),
                        IconButton(
                          icon: const Icon(Icons.g_mobiledata,
                              size: 40, color: Colors.red),
                          onPressed: () {}, // Lógica para Google Sign-in
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