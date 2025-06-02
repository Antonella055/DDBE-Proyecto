// lib/features/home/presentation/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:ayudantia_software/main.dart'; // Import your global supabase instance
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _darkMode = false;
  bool _underlineLinks = false;
  bool _readableFont = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Use the global supabase instance
  // final SupabaseService _supabaseService = SupabaseService(); // This might be redundant if you're using the global supabase client directly

  // If SupabaseService has other logic (e.g., image URL builders), keep it.
  // Otherwise, you can potentially remove it if its only purpose is to access the client.
  final SupabaseService _supabaseService = SupabaseService();


  // Access the global supabase client directly
  final SupabaseClient _supabaseClient = supabase; // Get the client from main.dart

  TextStyle get _textStyle => TextStyle(
        fontSize: _fontSize,
        fontFamily: _readableFont ? 'Arial' : 'Roboto',
        color: _darkMode ? Colors.white : Colors.black,
        decoration: _underlineLinks ? TextDecoration.underline : TextDecoration.none,
      );

  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  Color get _linkTextColor => _highContrast ? Colors.black : Colors.white;

  // Method to handle profile icon press
  void _onProfileIconPressed() {
    // Check if the user is currently logged in
    if (_supabaseClient.auth.currentUser == null) {
      // User is NOT logged in, navigate to LoginPage
      Navigator.of(context).pushNamed('/login');
    } else {
      // User IS logged in, navigate to ProfilePage
      Navigator.of(context).pushNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        linkTextColor: _linkTextColor,
        onProfileIconPressed: _onProfileIconPressed, // Pass the callback here
      ),
      body: Container(
        color: _backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección principal con márgenes aumentados
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLargeScreen)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.accessibility_new, color: Colors.white, size: 30),
                                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                                ),
                              ),
                            ),
                          SizedBox(height: isLargeScreen ? 24 : 0),
                          Text(
                            'Dirección de Desarrollo y\nBienestar Estudiantil DDBE',
                            style: _textStyle.copyWith(
                              fontSize: _fontSize + 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'DDBE',
                            style: _textStyle.copyWith(
                              fontSize: _fontSize + 4,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _supabaseService.getPublicImageUrl('images', 'upload/imagen1.jpg'),
                          fit: BoxFit.cover,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => Text(
                            'Error al cargar imagen1.jpg',
                            style: _textStyle.copyWith(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sección de "Dependencia adscrita"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _supabaseService.getPublicImageUrl('images', 'upload/imagen2.jpg'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            'Error al cargar imagen2.jpg',
                            style: _textStyle.copyWith(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Dependencia adscrita al Decanato de Estudiantes'),
                          const SizedBox(height: 16),
                          _buildParagraph(
                              'La Dirección de Desarrollo y Bienestar Estudiantil (DDBE) tiene como función principal '
                              'dirigir, planificar, controlar y evaluar los programas orientados a la atención integral '
                              'de la población estudiantil en los aspectos de crecimiento, desarrollo personal y '
                              'asesoramiento psicológico, garantizando la adecuada proyección de los recursos '
                              'necesarios para el logro de los objetivos estratégicos del año de Rectoría de la '
                              'Universidad acordes con los indicadores de bienestar y retención estudiantil previstos '
                              'por la institución y siguiendo los lineamientos del Decanato de Estudiantes.'),
                          const SizedBox(height: 16),
                          _buildParagraph(
                              'Asimismo, cuenta con la Gerencia de Asesoramiento y Desarrollo Estudiantil, y la '
                              'Gerencia de Atención Socioeconómica Estudiantil.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              CustomFooter(
                textColor: _darkMode ? Colors.white : Colors.black,
                backgroundColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ],
          ),
        ),
      ),

      endDrawer: AccessibilityDrawer(
        fontSize: _fontSize,
        highContrast: _highContrast,
        darkMode: _darkMode,
        underlineLinks: _underlineLinks,
        readableFont: _readableFont,
        onFontSizeChanged: (newSize) => setState(() => _fontSize = newSize),
        onHighContrastChanged: (value) => setState(() => _highContrast = value),
        onDarkModeChanged: (value) => setState(() => _darkMode = value),
        onUnderlineLinksChanged: (value) => setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) => setState(() => _readableFont = value),
        onReset: () => setState(() {
          _fontSize = 16.0;
          _highContrast = false;
          _darkMode = false;
          _underlineLinks = false;
          _readableFont = true;
        }),
        appBarColor: _appBarColor,
        linkTextColor: _linkTextColor,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: _textStyle.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: _fontSize + 4,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: _textStyle.copyWith(fontSize: _fontSize),
      textAlign: TextAlign.justify,
    );
  }
}