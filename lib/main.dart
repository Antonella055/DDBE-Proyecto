
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer; // Importar para usar developer.log

// Importa las páginas de Antonella

import 'package:ayudantia_software/features/auth/presentation/pages/login_page.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/profile_page.dart'; // Podría ser la página post-login si es admin/profesor

// Importa tu HomeScreen
import 'package:ayudantia_software/features/home/presentation/pages/home_screen.dart'; // ¡Asegúrate de la ruta correcta si la moviste!

// NEW: Importa la pantalla de noticias
import 'package:ayudantia_software/features/home/presentation/pages/news_screen.dart'; // Importa la pantalla de noticias

//import 'package:ayudantia_software/features/home/presentation/pages/schedule_screen.dart'; // Importa la pantalla de cronograma
import 'package:ayudantia_software/features/home/presentation/pages/contact_screen.dart';
 // Importa la pantalla de contacto

import 'package:ayudantia_software/features/home/presentation/pages/calendar_screen.dart';


// Variable global de Supabase
final supabase = Supabase.instance.client;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

¿
  // Cargar variables de entorno
  try {
    await dotenv.load();
  } catch (_) {
    // Manejar el error si .env no se carga (quizás solo en producción)
    developer.log('Error loading .env file, proceeding without it.', name: 'main'); // Usando developer.log
  }

  // Inicialización de Supabase

  await Supabase.initialize(
    url: 'https://lbxkcilriktsmfiruvfj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxieGtjaWxyaWt0c21maXJ1dmZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDA4NjYsImV4cCI6MjA2MzA3Njg2Nn0.Vtt_SYj5NWdg6j6JWcA2M_qdaPM0YhI8gcYsuG0pMSI',
  );

  // REMOVE THIS LINE: setupDependencies();

  runApp(const MyApp());
}

// RE-ADD THE GLOBAL SUPABASE INSTANCE
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Escucha los cambios de autenticación
    supabase.auth.onAuthStateChange.listen((data) {
      // final AuthChangeEvent event = data.event; // Variable 'event' eliminada
      // Puedes añadir lógica aquí para notificar a la UI sobre cambios de sesión
      // developer.log('Auth event: ${data.event}', name: 'auth'); // Para depuración, usando developer.log
      if (mounted) {
        setState(() {}); // Fuerza un redibujo para que la pantalla inicial cambie
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayudantia Unimet App', // Puedes elegir el título que prefieras
      debugShowCheckedModeBanner: false, // Quita el banner de debug
      theme: ThemeData(
        fontFamily: 'Arial', // Tu fuente preferida
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00), // Naranja corporativo (tu color)
          primary: const Color(0xFF673AB7), // Morado corporativo (tu color)
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Temas de botones de Antonella (puedes ajustarlos a tus colores si quieres)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 206, 124, 31),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 206, 124, 31),
          ),
        ),
      ),

      // Lógica de navegación condicional basada en el estado de autenticación
      home: supabase.auth.currentSession == null
          ? const HomeScreen() // Si no hay sesión, muestra tu HomeScreen
          : const ProfilePage(), // Si hay sesión, muestra ProfilePage (o una página de dashboard de usuario)
      // También puedes usar named routes para una navegación más flexible
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/news': (context) => const NewsScreen(), // NEW: Añade la ruta para NewsScreen
        '/calendar': (context) => const CalendarScreen(), // NEW: Añade la ruta para NewsScreen
       // '/schedule': (context) => const ScheduleScreen(), // Ruta de ScheduleScreen comentada
        '/contact': (context) => const ContactScreen(), // Añade la ruta para ContactScreen
        // Añade otras rutas para admin, profesor, etc. si las tienes

      },
    );
  }
}

// Extensión Context de Antonella
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color.fromARGB(255, 211, 47, 47)
            : const Color.fromARGB(255, 76, 175, 80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}