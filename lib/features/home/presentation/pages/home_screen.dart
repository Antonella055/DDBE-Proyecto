import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart';

const String backgroundUrl = 'https://lbxkcilriktsmfiruvfj.supabase.co/storage/v1/object/public/backgrounds/backgrounds/campus.jpg';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Colores institucionales
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  // Estados para accesibilidad
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _darkMode = false;
  bool _underlineLinks = false;
  bool _readableFont = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Modos de color
  bool _grayscale = false;
  bool _negativeContrast = false;
  bool _lightBackground = true;

  // Roles de usuario
  bool _isProfessor = false;
  bool _isStudent = false;
  bool _isLoadingRole = true;

  
  final SupabaseClient _supabaseClient = supabase;

  // Estilos adaptables
  TextStyle get _textStyle => TextStyle(
    fontSize: _fontSize,
    fontFamily: _readableFont ? 'Roboto' : 'Arial',
    color: _darkMode ? Colors.white : darkBlue,
    decoration: _underlineLinks ? TextDecoration.underline : TextDecoration.none,
  );

  Color get _backgroundColor => _darkMode ? darkBackground : lightBackground;
  Color get _appBarColor => _highContrast ? primaryOrange : darkBlue;
  Color get _primaryColor => primaryOrange;
  Color get _textColor => _darkMode ? Colors.white : darkBlue;
  Color get _cardColor => _darkMode ? Colors.grey[800]! : Colors.white;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final String? userId = _supabaseClient.auth.currentUser?.id;
    if (userId != null) {
      try {
        final professorResult = await _supabaseClient
            .from('professors')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        final studentResult = await _supabaseClient
            .from('students')
            .select()
            .eq('id', userId)
            .maybeSingle();

        setState(() {
          _isProfessor = professorResult != null;
          _isStudent = studentResult != null;
          _isLoadingRole = false;
        });
      } catch (e) {
        setState(() {
          _isProfessor = false;
          _isStudent = false;
          _isLoadingRole = false;
        });
        debugPrint('Error verificando rol: $e');
      }
    } else {
      setState(() {
        _isProfessor = false;
        _isStudent = false;
        _isLoadingRole = false;
      });
    }
  }

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

  Color _applyColorFilters(Color color) {
    if (_grayscale) return Color.lerp(Colors.grey, color, 0.1)!;
    if (_negativeContrast) {
      return Color.fromRGBO(
        255 - color.red,
        255 - color.green,
        255 - color.blue,
        color.opacity,
      );
    }
    return color;
  }

  void _handleMenuSelection(String value) {
    final String? userId = _supabaseClient.auth.currentUser?.id;
    
    if (value == 'horas_culminadas' && userId != null) {
      Navigator.of(context).pushNamed(
        '/student-hours',
        arguments: {'studentId': userId},
      );
    } else if (value == 'dashboard_profesor' && userId != null) {
      Navigator.of(context).pushNamed(
        '/professor-dashboard',
        arguments: {'professorId': userId},
      );
    } else if (value == 'solicitar_ayudantia') {
      Navigator.of(context).pushNamed('/request-assistant');
    } else if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes iniciar sesión para acceder a esta función'),
          backgroundColor: _applyColorFilters(primaryOrange),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/',
        onProfileIconPressed: _onProfileIconPressed,
        isProfessor: _isProfessor,
        actions: [
          IconButton(
            icon: Icon(Icons.accessibility_new, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              if (_isStudent) ...[
                const PopupMenuItem<String>(
                  value: 'horas_culminadas',
                  child: Text('Mis horas de ayudantía'),
                ),
                const PopupMenuItem<String>(
                  value: 'solicitar_ayudantia',
                  child: Text('Solicitar ayudantía'),
                ),
              ],
              if (_isProfessor)
                const PopupMenuItem<String>(
                  value: 'dashboard_profesor',
                  child: Text('Panel de profesor'),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _applyColorFilters(_backgroundColor),
          gradient: !_grayscale && !_highContrast && !_negativeContrast
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _darkMode
                      ? [darkBackground, Colors.grey[900]!]
                      : [lightBackground, Colors.white],
                )
              : null,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(isLargeScreen),
              _buildStatsSection(),
              _buildBenefitsSection(isLargeScreen),
              _buildHowItWorksSection(),
              if (_isLoadingRole)
                _buildLoadingIndicator()
              else
                CustomFooter(
                  textColor: _applyColorFilters(_textColor),
                  backgroundColor: _applyColorFilters(_cardColor),
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
        onDarkModeChanged: (value) => setState(() {
          _darkMode = value;
          _lightBackground = !value;
        }),
        onUnderlineLinksChanged: (value) => setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) => setState(() => _readableFont = value),
        onGrayscaleChanged: (value) => setState(() {
          _grayscale = value;
          if (value) _negativeContrast = false;
        }),
        onNegativeContrastChanged: (value) => setState(() {
          _negativeContrast = value;
          if (value) _grayscale = false;
        }),
        onLightBackgroundChanged: (value) => setState(() {
          _lightBackground = value;
          _darkMode = !value;
        }),
        onReset: _resetAccessibilitySettings,
        appBarColor: _applyColorFilters(_appBarColor),
        linkTextColor: _applyColorFilters(_primaryColor),
      ),
    );
  }

  Widget _buildHeroSection(bool isLargeScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 48 : 24,
        vertical: 100,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        image: DecorationImage(
          image: NetworkImage(backgroundUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sistema de Ayudantías Universitarias',
            style: TextStyle(
              fontSize: _fontSize + (isLargeScreen ? 14 : 10),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.7),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Conectando estudiantes y profesores para un mejor aprendizaje',
            style: TextStyle(
              fontSize: _fontSize + 2,
              color: Colors.white.withOpacity(0.95),
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildHeroButtons(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeroButtons() {
    if (_supabaseClient.auth.currentUser == null) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: darkBlue,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
        ),
      ];
    } else if (_isStudent) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/request-assistant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Solicitar Ayudantía',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
        ),
      ];
    } else if (_isProfessor) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/professor-dashboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Panel de Profesor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
            ),
          ),
        ),
      ];
    }
    return [];
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60), // Más espacio vertical
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'NUESTRO IMPACTO',
            style: TextStyle(
              fontSize: _fontSize + 12,
              fontWeight: FontWeight.bold,
              color: _applyColorFilters(darkBlue),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 100,
            height: 4,
            color: _applyColorFilters(primaryOrange),
          ),
          SizedBox(height: 40),
          Container(
            constraints: BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: [
                _buildStatCard('500+', 'Ayudantías asignadas', Icons.assignment_turned_in),
                _buildStatCard('120+', 'Profesores participantes', Icons.school),
                _buildStatCard('300+', 'Estudiantes beneficiados', Icons.people_alt),
                _buildStatCard('98%', 'Satisfacción general', Icons.sentiment_very_satisfied),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 240,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: _applyColorFilters(accentBlue.withOpacity(0.3)),
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _applyColorFilters(accentBlue.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: _applyColorFilters(accentBlue),
                ),
              ),
              SizedBox(height: 20),
              Text(
                value,
                style: TextStyle(
                  fontSize: _fontSize + 20,
                  fontWeight: FontWeight.bold,
                  color: _applyColorFilters(darkBlue),
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: _fontSize + 2,
                  color: _applyColorFilters(darkBlue.withOpacity(0.8)),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://lbxkcilriktsmfiruvfj.supabase.co/storage/v1/object/public/backgrounds/patterns/abstract-wave.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            _applyColorFilters(accentBlue.withOpacity(0.05)),
            BlendMode.multiply,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'BENEFICIOS',
                  style: TextStyle(
                    fontSize: _fontSize + 12,
                    fontWeight: FontWeight.bold,
                    color: _applyColorFilters(darkBlue),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 4,
                  color: _applyColorFilters(primaryOrange),
                ),
                SizedBox(height: 40),
                GridView.count(
                  crossAxisCount: isLargeScreen ? 3 : 1,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: isLargeScreen ? 1.1 : 1.3,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                  children: [
                    _buildBenefitCard(
                      icon: Icons.school,
                      title: 'Para Estudiantes',
                      benefits: [
                        'Gana experiencia docente',
                        'Refuerza tus conocimientos',
                        'Genera ingresos adicionales',
                        'Horas válidas para tu CV',
                      ],
                      color: _applyColorFilters(accentBlue),
                    ),
                    _buildBenefitCard(
                      icon: Icons.people,
                      title: 'Para Profesores',
                      benefits: [
                        'Apoyo en labores docentes',
                        'Asistentes capacitados',
                        'Mejora el rendimiento',
                        'Seguimiento integrado',
                      ],
                      color: _applyColorFilters(primaryOrange),
                    ),
                    _buildBenefitCard(
                      icon: Icons.auto_awesome,
                      title: 'Para la Universidad',
                      benefits: [
                        'Mejora académica',
                        'Fomenta comunidad',
                        'Sistema centralizado',
                        'Transparencia total',
                      ],
                      color: _applyColorFilters(darkBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required List<String> benefits,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _fontSize + 6,
                    fontWeight: FontWeight.bold,
                    color: _applyColorFilters(darkBlue),
                  ),
                ),
                SizedBox(height: 16),
                ...benefits.map((benefit) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: color,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: _fontSize + 1,
                            color: _applyColorFilters(darkBlue.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _applyColorFilters(accentBlue.withOpacity(0.1)),
            _applyColorFilters(lightBackground),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '¿Cómo funciona?',
            style: _textStyle.copyWith(
              fontSize: _fontSize + 10,
              fontWeight: FontWeight.bold,
              color: _applyColorFilters(darkBlue),
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _buildStepsProcess(),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Únete a nuestra comunidad académica y sé parte de la transformación educativa',
              style: _textStyle.copyWith(
                fontSize: _fontSize + 4,
                color: _applyColorFilters(darkBlue),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          
        ],
      ),
    );
  }

  Widget _buildStepsProcess() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _applyColorFilters(_cardColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProcessStep(
            step: 1,
            title: 'Registro',
            description: 'Completa tu perfil como estudiante o profesor',
            icon: Icons.person_add,
          ),
          _buildStepDivider(),
          _buildProcessStep(
            step: 2,
            title: 'Solicitud',
            description: 'Estudiantes solicitan ayudantías en materias disponibles',
            icon: Icons.send,
          ),
          _buildStepDivider(),
          _buildProcessStep(
            step: 3,
            title: 'Aprobación',
            description: 'Profesores revisan y aprueban las solicitudes',
            icon: Icons.verified,
          ),
          _buildStepDivider(),
          _buildProcessStep(
            step: 4,
            title: 'Seguimiento',
            description: 'Registro de horas y actividades realizadas',
            icon: Icons.timeline,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _applyColorFilters(primaryOrange.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _applyColorFilters(primaryOrange),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  fontSize: _fontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: _applyColorFilters(primaryOrange),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: _applyColorFilters(accentBlue),
                    ),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: _textStyle.copyWith(
                        fontSize: _fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: _applyColorFilters(darkBlue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: _textStyle.copyWith(
                    color: _applyColorFilters(_textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        color: _applyColorFilters(Colors.grey[300]!),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          _applyColorFilters(primaryOrange),
        ),
      ),
    );
  }

}