import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/screens/home_screen.dart'; // ¡Aquí el cambio!
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Reemplaza con tu URL y clave anon de Supabase
  // Puedes encontrarlas en tu proyecto Supabase -> Settings -> API
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
      title: 'DDBE - Bienestar Estudiantil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00), // Naranja corporativo
          primary: const Color(0xFF673AB7), // Morado corporativo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Aquí apuntamos a la pantalla de inicio
    );
  }
}