import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart'; // Asegúrate de que main.dart exporta 'supabase'
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/activity_calendar.dart'; // Importa el calendario de actividades
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart'; // Importa el Drawer de accesibilidad


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Estados de accesibilidad (puedes copiarlos de NewsScreen si quieres coherencia)
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _darkMode = false;
  bool _underlineLinks = false;
  bool _readableFont = true;
  bool _grayscale = false;
  bool _negativeContrast = false;
  bool _lightBackground = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SupabaseClient _supabaseClient = supabase; // Instancia de Supabase

  // Getter para el color del texto de los enlaces de la AppBar
  Color get _linkTextColor => _darkMode ? Colors.white : Colors.blue;

  // Getter para el color de fondo de la pantalla
  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;

  // Getter para el color del texto principal
  Color get _textColor => _darkMode ? Colors.white : Colors.black;

  // Getter para el color de la AppBar (si quieres que cambie con el contraste)
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);


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
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        linkTextColor: _linkTextColor,
        onProfileIconPressed: _onProfileIconPressed,
      ),
      body: Container(
        color: _backgroundColor, // Fondo de la pantalla
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Cronograma de Actividades',
                  style: TextStyle(
                    fontSize: _fontSize + 12,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ActivityCalendar(
                  textColor: _textColor,
                  backgroundColor: _darkMode ? Colors.grey[800]! : Colors.white, // Fondo del calendario
                ),
              ),
              const SizedBox(height: 32.0),
              CustomFooter(
                textColor: _textColor,
                backgroundColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!, // Fondo del footer
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
}