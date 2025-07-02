// lib/main.dart
import 'package:ayudantia_software/features/auth/presentation/pages/admin_create_professor.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import 'package:ayudantia_software/features/auth/presentation/pages/login_page.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/profile_page.dart';
import 'package:ayudantia_software/features/home/presentation/pages/home_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/news_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/contact_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/calendar_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/professor_dashboard_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/horas_culminadas_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/postulation_screen.dart';
import 'package:ayudantia_software/features/home/presentation/pages/help_request_screen.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/admin_create_student.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load();
  } catch (_) {
    developer.log(
      'Error loading .env file, proceeding without it.',
      name: 'main',
    );
  }

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://lbxkcilriktsmfiruvfj.supabase.co', // Tu URL de Supabase
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxieGtjaWxyaWt0c21maXJ1dmZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDA4NjYsImV4cCI6MjA2MzA3Njg2Nn0.Vtt_SYj5NWdg6j6JWcA2M_qdaPM0YhI8gcYsuG0pMSI', // Tu clave anon de Supabase
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayudantia Unimet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),
          primary: const Color(0xFFF57C00),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
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
      home:
          supabase.auth.currentSession == null
              ? const HomeScreen()
              : const ProfilePage(),
      // Rutas de navegación
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/news': (context) => const NewsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/contact': (context) => const ContactScreen(),
        // Ruta para el dashboard del profesor
        '/dashboard': (context) {
          print('Entrando a la ruta /dashboard');
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          print('Argumentos recibidos: $args');
          final idSupervisor = args?['id_supervisor'];
          print('idSupervisor extraído: $idSupervisor');
          if (idSupervisor == null) {
            print('No se proporcionó ID de supervisor');
            return const Scaffold(
              body: Center(
                child: Text('Error: No se proporcionó ID de supervisor'),
              ),
            );
          }
          print('Navegando a ProfessorDashboardScreen con id: $idSupervisor');
          return ProfessorDashboardScreen(professorId: idSupervisor);
        },
        '/horas_estudiante': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final idEstudiante = args?['idEstudiante'];
          if (idEstudiante == null) {
            return const Scaffold(
              body: Center(child: Text('No se proporcionó idEstudiante')),
            );
          }
          return HorasCulminadasScreen(estudianteId: idEstudiante);
        },
        '/postulation': (context) => const AyudantiaPage(),
        '/create-student': (context) => const AdminCreateStudent(),
        '/create-professor': (context) => const AdminCreateProfessor(),
        '/help': (context) => const HelpRequestScreen(),
        '/reset-password': (context) {
          final uri = Uri.base;
          final codeFromUrl = uri.queryParameters['code'];
          return ResetPasswordPage(code: codeFromUrl);
        },
      },
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? const Color.fromARGB(255, 211, 47, 47)
                : const Color.fromARGB(255, 76, 175, 80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
