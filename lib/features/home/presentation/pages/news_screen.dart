// features/home/presentation/pages/news_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart'; // Corregido el nombre del archivo si es 'accesibility'
import 'package:ayudantia_software/features/home/data/news_model.dart'; // Importa el modelo de noticia

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
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

  late Future<List<NewsArticle>> _newsArticlesFuture;

  @override
  void initState() {
    super.initState();
    _newsArticlesFuture = _supabaseService.fetchNewsArticles();
  }

  TextStyle get _textStyle => TextStyle(
        fontSize: _fontSize,
        fontFamily: _readableFont ? 'Arial' : 'Roboto',
        color: _darkMode ? Colors.white : Colors.black,
        decoration: _underlineLinks ? TextDecoration.underline : TextDecoration.none,
      );

  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
   
  // Modificado para que el color de la AppBar sea fijo o basado en highContrast
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  // Modificado para que el color del texto de los enlaces se adapte al modo oscuro
  Color get _linkTextColor => _darkMode ? Colors.white : Colors.blue;  

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
        color: _backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Noticias Recientes',
                  style: _textStyle.copyWith(
                    fontSize: _fontSize + 12,
                    fontWeight: FontWeight.bold,
                    color: _darkMode ? Colors.white : Colors.black87, // Color del título adaptable al modo oscuro
                  ),
                ),
              ),
              FutureBuilder<List<NewsArticle>>(
                future: _newsArticlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Error al cargar las noticias: ${snapshot.error}',
                      style: _textStyle.copyWith(color: Colors.red),
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                      'No hay noticias disponibles.',
                      style: _textStyle,
                    ));
                  } else {
                    final List<NewsArticle> news = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: isLargeScreen
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, // 3 columnas para pantallas grandes
                                crossAxisSpacing: 24.0,
                                mainAxisSpacing: 24.0,
                                childAspectRatio: 0.8, // Ajusta si la tarjeta es muy alta/ancha
                              ),
                              itemCount: news.length,
                              itemBuilder: (context, index) {
                                return _buildNewsCard(news[index]);
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: news.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildNewsCard(news[index]),
                                );
                              },
                            ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32.0),
              CustomFooter(
                textColor: _darkMode ? Colors.white : Colors.black,
                backgroundColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ],
          ),
        ),
      ),
      // ¡Aquí está la corrección para el Drawer!
      endDrawer: AccessibilityDrawer(
        fontSize: _fontSize,
        highContrast: _highContrast,
        darkMode: _darkMode, // Mantener si controla el tema general
        underlineLinks: _underlineLinks,
        readableFont: _readableFont,
        
        // ¡Pasar los nuevos estados!
        grayscale: _grayscale,
        negativeContrast: _negativeContrast,
        lightBackground: _lightBackground, // Pasando el estado de fondo claro

        onFontSizeChanged: (newSize) => setState(() => _fontSize = newSize),
        onHighContrastChanged: (value) => setState(() => _highContrast = value),
        onDarkModeChanged: (value) {
          setState(() {
            _darkMode = value;
            // Opcional: si _darkMode afecta _lightBackground
            _lightBackground = !value;  
          });
        },
        onUnderlineLinksChanged: (value) => setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) => setState(() => _readableFont = value),
        
        // ¡Pasar los nuevos callbacks!
        onGrayscaleChanged: (value) {
          setState(() {
            _grayscale = value;
            if (value) _negativeContrast = false; // Lógica de exclusión
          });
        },
        onNegativeContrastChanged: (value) {
          setState(() {
            _negativeContrast = value;
            if (value) _grayscale = false; // Lógica de exclusión
          });
        },
        onLightBackgroundChanged: (value) {
          setState(() {
            _lightBackground = value;
            // Opcional: si _lightBackground afecta _darkMode
            _darkMode = !value;
          });
        },
        
        onReset: _resetAccessibilitySettings, // Usar el método actualizado
        appBarColor: _appBarColor, // Pasar el color de la AppBar (del getter)
        linkTextColor: _linkTextColor, // Pasar el color de los enlaces (del getter)
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: _darkMode ? Colors.grey[700] : Colors.white, // Color de la tarjeta adaptable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                ? Image.network(
                    _supabaseService.getPublicImageUrl('images', article.imageUrl!),
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: _darkMode ? Colors.grey[600] : Colors.grey[200], // Fondo mientras carga adaptable
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(_appBarColor), // Color del indicador adaptable
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      final imageUrlToLoad = _supabaseService.getPublicImageUrl('images', article.imageUrl!);
                      print('DEBUG: Error en Image.network para URL: $imageUrlToLoad');
                      print('DEBUG: Tipo de Error: ${error.runtimeType}');
                      print('DEBUG: Mensaje de Error: $error');
                      print('DEBUG: Stack Trace: $stackTrace');

                      return Container(
                        height: 180,
                        color: _darkMode ? Colors.grey[600] : Colors.grey[300], // Color de error adaptable
                        child: Center(
                          child: Text(
                            'Error al cargar imagen o no disponible: \n${imageUrlToLoad}\nError: $error',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _darkMode ? Colors.redAccent : Colors.red, // Color del texto de error adaptable
                              fontSize: 10
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: _darkMode ? Colors.grey[600] : Colors.grey[400], // Placeholder adaptable
                    child: Center(
                      child: Text(
                        'Imagen no disponible',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: _textStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize + 2,
                    color: _darkMode ? Colors.white : Colors.black87, // Color del título adaptable
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.description,
                  style: _textStyle.copyWith(
                    fontSize: _fontSize,
                    color: _darkMode ? Colors.white70 : Colors.black87, // Color de descripción adaptable
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      debugPrint('Leer más: ${article.title}');
                    },
                    child: Text(
                      'Leer más',
                      style: _textStyle.copyWith(
                        color: _linkTextColor, // Usar el color del enlace adaptable
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}