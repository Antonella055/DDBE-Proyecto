import 'package:ayudantia_software/features/auth/presentation/pages/admin_create_professor.dart';
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

  // Inicialización de Supabase con configuración de autenticación
  await Supabase.initialize(
    url: 'https://lbxkcilriktsmfiruvfj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxieGtjaWxyaWt0c21maXJ1dmZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDA4NjYsImV4cCI6MjA2MzA3Njg2Nn0.Vtt_SYj5NWdg6j6JWcA2M_qdaPM0YhI8gcYsuG0pMSI',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
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
      home: supabase.auth.currentSession == null
          ? const HomeScreen()
          : const ProfilePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/news': (context) => const NewsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/contact': (context) => const ContactScreen(),
        '/postulation': (context) => const AyudantiaPage(),
        '/create-student': (context) => const AdminCreateStudent(),
        '/create-professor': (context) => const AdminCreateProfessor(),
        '/help': (context) => const HelpRequestScreen(),
        
      },
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color.fromARGB(255, 211, 47, 47)
            : const Color.fromARGB(255, 76, 175, 80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}