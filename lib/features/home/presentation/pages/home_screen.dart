// lib/features/home/presentation/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
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
  // Estados para la accesibilidad
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _darkMode = false;
  bool _underlineLinks = false;
  bool _readableFont = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Nuevas variables de estado para los modos de color/contraste
  bool _grayscale = false;
  bool _negativeContrast = false;
  bool _lightBackground = true; // Por defecto, fondo claro

  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient = supabase;

  // Estilos de texto adaptables
  TextStyle get _textStyle => TextStyle(
        fontSize: _fontSize,
        fontFamily: _readableFont ? 'Roboto' : 'Roboto',
        color: _darkMode ? Colors.white : Colors.black,
        decoration: _underlineLinks ? TextDecoration.underline : TextDecoration.none,
      );

  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  Color get _linkTextColor => _darkMode ? Colors.white : Colors.blue;

  void _onProfileIconPressed() {
    if (_supabaseClient.auth.currentUser == null) {
      Navigator.of(context).pushNamed('/login');
    } else {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  void _resetAccessibilitySettings() {
    setState(() {
      _fontSize = 16.0;
      _highContrast = false;
      _darkMode = false;
      _underlineLinks = false;
      _readableFont = true;
      _grayscale = false;
      _negativeContrast = false;
      _lightBackground = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/',
        onProfileIconPressed: _onProfileIconPressed,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'horas_culminadas') {
                final String? idEstudiante = Supabase.instance.client.auth.currentUser?.id;
                if (idEstudiante != null) {
                  Navigator.pushNamed(
                    context,
                    '/horas_estudiante',
                    arguments: {'idEstudiante': idEstudiante},
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo obtener el ID del estudiante.')),
                  );
                }
              }
              // Puedes agregar más opciones aquí si lo deseas
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'horas_culminadas',
                child: Text('Ver horas culminadas'),
              ),
              // Otros PopupMenuItem si quieres más opciones
            ],
          ),
        ],
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
                                  color: _appBarColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.accessibility_new,
                                    color: _linkTextColor,
                                    size: 30,
                                  ),
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
                              color: _darkMode ? Colors.white : Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'DDBE',
                            style: _textStyle.copyWith(
                              fontSize: _fontSize + 4,
                              fontWeight: FontWeight.w500,
                              color: _darkMode ? Colors.grey[400] : Colors.grey[700],
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: _darkMode ? Colors.grey[600] : Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Error al cargar imagen1.jpg',
                                style: _textStyle.copyWith(
                                  color: _darkMode ? Colors.redAccent : Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: _darkMode ? Colors.grey[700] : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(_appBarColor),
                                ),
                              ),
                            );
                          },
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
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: _darkMode ? Colors.grey[600] : Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Error al cargar imagen2.jpg',
                                style: _textStyle.copyWith(
                                  color: _darkMode ? Colors.redAccent : Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: _darkMode ? Colors.grey[700] : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(_appBarColor),
                                ),
                              ),
                            );
                          },
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
                            'por la institución y siguiendo los lineamientos del Decanato de Estudiantes.',
                          ),
                          const SizedBox(height: 16),
                          _buildParagraph(
                            'Asimismo, cuenta con la Gerencia de Asesoramiento y Desarrollo Estudiantil, y la '
                            'Gerencia de Atención Socioeconómica Estudiantil.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Botón para ir al Dashboard de Profesor
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final String? tuIdSupervisor = Supabase.instance.client.auth.currentUser?.id;
                      if (tuIdSupervisor != null) {
                        Navigator.pushNamed(
                          context,
                          '/dashboard',
                          arguments: {'id_supervisor': tuIdSupervisor},
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo obtener el ID del profesor.')),
                        );
                      }
                    },
                    child: const Text('Ir al Dashboard de Profesor'),
                  ),
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
        grayscale: _grayscale,
        negativeContrast: _negativeContrast,
        lightBackground: _lightBackground,
        onFontSizeChanged: (newSize) => setState(() => _fontSize = newSize),
        onHighContrastChanged: (value) => setState(() => _highContrast = value),
        onDarkModeChanged: (value) {
          setState(() {
            _darkMode = value;
            _lightBackground = !value;
          });
        },
        onUnderlineLinksChanged: (value) => setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) => setState(() => _readableFont = value),
        onGrayscaleChanged: (value) {
          setState(() {
            _grayscale = value;
            if (value) _negativeContrast = false;
          });
        },
        onNegativeContrastChanged: (value) {
          setState(() {
            _negativeContrast = value;
            if (value) _grayscale = false;
          });
        },
        onLightBackgroundChanged: (value) {
          setState(() {
            _lightBackground = value;
            _darkMode = !value;
          });
        },
        onReset: _resetAccessibilitySettings,
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
        color: _darkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: _textStyle.copyWith(
        fontSize: _fontSize,
        color: _darkMode ? Colors.white70 : Colors.black87,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
