import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart'; // Si necesitas el drawer en esta página
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
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  Color get _linkTextColor => _highContrast ? Colors.black : Colors.white;

  void _onProfileIconPressed() {
    if (_supabaseClient.auth.currentUser == null) {
      Navigator.of(context).pushNamed('/login');
    } else {
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
                    color: Colors.black87,
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

  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              _supabaseService.getPublicImageUrl('images', article.imageUrl), // Asume que `imageUrl` es la ruta en el bucket 'images'
              fit: BoxFit.cover,
              height: 180, // Altura fija para las imágenes de las noticias
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Error al cargar imagen: ${article.imageUrl}',
                    style: _textStyle.copyWith(color: Colors.red, fontSize: _fontSize - 2),
                    textAlign: TextAlign.center,
                  ),
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
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.description,
                  style: _textStyle.copyWith(fontSize: _fontSize),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      // Implementar navegación a la página de detalle de la noticia
                      print('Leer más: ${article.title}');
                      // Puedes usar Navigator.push para ir a una pantalla de detalle de la noticia
                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)));
                    },
                    child: Text(
                      'Leer más',
                      style: _textStyle.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
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