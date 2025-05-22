// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/login_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lbxkcilriktsmfiruvfj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxieGtjaWxyaWt0c21maXJ1dmZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDA4NjYsImV4cCI6MjA2MzA3Njg2Nn0.Vtt_SYj5NWdg6j6JWcA2M_qdaPM0YhI8gcYsuG0pMSI',
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayudantia Unimet App',
      theme: ThemeData(
        // Remueve primarySwatch y usa colorScheme en su lugar
        colorScheme: ColorScheme.fromSeed( // Usa fromSeed para generar un ColorScheme basado en un color semilla
          seedColor: const Color.fromARGB(255, 164, 98, 23), // Aquí puedes usar tu color naranja/marrón
          brightness: Brightness.light, // Puedes elegir light o dark
        ),
        // Si necesitas un color principal para el Theme.of(context).primaryColor directo
        // (aunque colorScheme es preferido con Material 3), puedes definirlo aquí.
        // Pero lo mejor es acceder a los colores a través de Theme.of(context).colorScheme.primary, etc.

        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // ¡Mantén esto en true para Material 3!
      ),
      home: const LoginPage(), // Tu página de inicio de sesión como punto de entrada
    );
  }
}