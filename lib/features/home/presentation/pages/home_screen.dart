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

  // ¡Nuevas variables de estado para los modos de color/contraste!
  bool _grayscale = false;
  bool _negativeContrast = false;
  bool _lightBackground = true; // Por defecto, fondo claro

  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient = supabase;

  // Estilos de texto adaptables
  TextStyle get _textStyle => TextStyle(
    fontSize: _fontSize,
    fontFamily: _readableFont ? 'Arial' : 'Roboto',
    color:
        _darkMode
            ? Colors.white
            : Colors.black, // Color adaptable al modo oscuro
    decoration:
        _underlineLinks ? TextDecoration.underline : TextDecoration.none,
  );

  Color get _backgroundColor =>
      _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get _appBarColor =>
      _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  Color get _linkTextColor =>
      _darkMode ? Colors.white : Colors.blue; // Color adaptable al modo oscuro

  // Método para manejar la acción del icono de perfil
  void _onProfileIconPressed() {
    if (_supabaseClient.auth.currentUser == null) {
      Navigator.of(context).pushNamed('/login');
    } else {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  // Método para restablecer las configuraciones de accesibilidad
  void _resetAccessibilitySettings() {
    setState(() {
      _fontSize = 16.0;
      _highContrast = false;
      _darkMode = false;
      _underlineLinks = false;
      _readableFont = true;
      // Reiniciar los nuevos estados
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
        linkTextColor: _linkTextColor,
        onProfileIconPressed: _onProfileIconPressed,
      ),
      body: Container(
        color: _backgroundColor, // Usar el color de fondo adaptable
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección principal con márgenes aumentados
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 32.0,
                ),
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
                                  color:
                                      _appBarColor, // Color adaptable al modo oscuro/alto contraste
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.accessibility_new,
                                    color: _linkTextColor,
                                    size: 30,
                                  ), // Color adaptable
                                  onPressed:
                                      () =>
                                          _scaffoldKey.currentState
                                              ?.openEndDrawer(),
                                ),
                              ),
                            ),
                          SizedBox(height: isLargeScreen ? 24 : 0),
                          Text(
                            'Dirección de Desarrollo y\nBienestar Estudiantil DDBE',
                            style: _textStyle.copyWith(
                              fontSize: _fontSize + 20,
                              fontWeight: FontWeight.w600,
                              color:
                                  _darkMode
                                      ? Colors.white
                                      : Colors.black87, // Color adaptable
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'DDBE',
                            style: _textStyle.copyWith(
                              fontSize: _fontSize + 4,
                              fontWeight: FontWeight.w500,
                              color:
                                  _darkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700], // Color adaptable
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
                          _supabaseService.getPublicImageUrl(
                            'images',
                            'upload/imagen1.jpg',
                          ),
                          fit: BoxFit.cover,
                          height: 200,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 200,
                                color:
                                    _darkMode
                                        ? Colors.grey[600]
                                        : Colors
                                            .grey[300], // Color de error adaptable
                                child: Center(
                                  child: Text(
                                    'Error al cargar imagen1.jpg',
                                    style: _textStyle.copyWith(
                                      color:
                                          _darkMode
                                              ? Colors.redAccent
                                              : Colors.red,
                                    ), // Color adaptable
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color:
                                  _darkMode
                                      ? Colors.grey[700]
                                      : Colors
                                          .grey[200], // Fondo mientras carga adaptable
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _appBarColor,
                                  ), // Color del indicador adaptable
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 32.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _supabaseService.getPublicImageUrl(
                            'images',
                            'upload/imagen2.jpg',
                          ),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height:
                                    200, // Asegura una altura para el contenedor de error
                                color:
                                    _darkMode
                                        ? Colors.grey[600]
                                        : Colors
                                            .grey[300], // Color de error adaptable
                                child: Center(
                                  child: Text(
                                    'Error al cargar imagen2.jpg',
                                    style: _textStyle.copyWith(
                                      color:
                                          _darkMode
                                              ? Colors.redAccent
                                              : Colors.red,
                                    ), // Color adaptable
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height:
                                  200, // Asegura una altura para el contenedor de carga
                              color:
                                  _darkMode
                                      ? Colors.grey[700]
                                      : Colors
                                          .grey[200], // Fondo mientras carga adaptable
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _appBarColor,
                                  ), // Color del indicador adaptable
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
                          _buildSectionTitle(
                            'Dependencia adscrita al Decanato de Estudiantes',
                          ),
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

              CustomFooter(
                textColor: _darkMode ? Colors.white : Colors.black,
                backgroundColor:
                    _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ],
          ),
        ),
      ),

      // ¡Aquí está la corrección para el Drawer!
      endDrawer: AccessibilityDrawer(
        fontSize: _fontSize,
        highContrast: _highContrast,
        darkMode: _darkMode,
        underlineLinks: _underlineLinks,
        readableFont: _readableFont,

        // ¡Pasar los nuevos estados!
        grayscale: _grayscale,
        negativeContrast: _negativeContrast,
        lightBackground: _lightBackground,

        onFontSizeChanged: (newSize) => setState(() => _fontSize = newSize),
        onHighContrastChanged: (value) => setState(() => _highContrast = value),
        onDarkModeChanged: (value) {
          setState(() {
            _darkMode = value;
            _lightBackground = !value; // Sincroniza con el modo oscuro
          });
        },
        onUnderlineLinksChanged:
            (value) => setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) => setState(() => _readableFont = value),

        // ¡Pasar los nuevos callbacks!
        onGrayscaleChanged: (value) {
          setState(() {
            _grayscale = value;
            if (value) _negativeContrast = false; // Lógica de exclusión mutua
          });
        },
        onNegativeContrastChanged: (value) {
          setState(() {
            _negativeContrast = value;
            if (value) _grayscale = false; // Lógica de exclusión mutua
          });
        },
        onLightBackgroundChanged: (value) {
          setState(() {
            _lightBackground = value;
            _darkMode = !value; // Sincroniza con el modo oscuro
          });
        },

        onReset: _resetAccessibilitySettings, // Usar el método actualizado
        appBarColor: _appBarColor, // Pasa el color de la AppBar (del getter)
        linkTextColor:
            _linkTextColor, // Pasa el color de los enlaces (del getter)
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: _textStyle.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: _fontSize + 4,
        color: _darkMode ? Colors.white : Colors.black87, // Color adaptable
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: _textStyle.copyWith(
        fontSize: _fontSize,
        color: _darkMode ? Colors.white70 : Colors.black87, // Color adaptable
      ),
      textAlign: TextAlign.justify,
    );
  }
}
