import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:ayudantia_software/main.dart'; // Import your global supabase instance
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/services/supabase_service.dart'; // Import your SupabaseService

class AyudantiaPage extends StatefulWidget {
  const AyudantiaPage({super.key});

  @override
  State<AyudantiaPage> createState() => _AyudantiaPageState();
}

class _AyudantiaPageState extends State<AyudantiaPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient =
      supabase; // Get the client from main.dart
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for CustomAppBar

  void _abrirPDF() async {
    // Construct the URL for the PDF in Supabase Storage
    final String pdfUrl = _supabaseService.getPublicImageUrl(
      'documents', // Your Supabase bucket name for documents
      'REGLAMENTO-DEL-PROGRAMA-AYUDANTIA-UNIMET-2023 (1).pdf', // The exact path to your PDF file
    );

    final Uri url = Uri.parse(pdfUrl);
    debugPrint('Attempting to launch PDF URL: $pdfUrl'); // Debugging print

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // It's good practice to show an error to the user.
      if (mounted) { // Ensure the widget is still in the tree before showing a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el PDF: $pdfUrl')),
        );
      }
    }
  }

  // Method to handle profile icon press (needed for CustomAppBar)
  void _onProfileIconPressed() {
    if (_supabaseClient.auth.currentUser == null) {
      Navigator.of(context).pushNamed('/login');
    } else {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the image URL for debugging purposes
    final String imageUrl = _supabaseService.getPublicImageUrl(
      'images', // Your bucket name for images
      'upload/imagen4.png', // The path within the images bucket
    );
    debugPrint('Generated Image URL: $imageUrl'); // Print the image URL to console

    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey, // Pass the scaffold key
        currentRoute: '/ayudantia', // ¡Aquí se pasa la ruta actual, que es '/ayudantia'!
        onProfileIconPressed: _onProfileIconPressed, // Pass the callback
        linkTextColor: Colors.orange, // Add the required linkTextColor argument
        // No es necesario pasar hasDropdown para "Más" si ya no tiene dropdown
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Columna izquierda
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Programa de Ayudantía',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Es un programa de intercambio de valor para los estudiantes de pregrado y postgrado de la universidad. '
                    'Los estudiantes colaborarán en actividades académicas (Programa de Mentoría) o administrativas dentro del campus universitario, '
                    'bajo la supervisión del personal de la universidad.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de postulación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Las postulaciones para este programa se realizarán desde la semana 2 hasta la semana 4.\n'
                          'Postulación al Programa de Ayudantía 2526-1',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
             ElevatedButton(
                  onPressed: () async {
                    const url = 'https://docs.google.com/forms/d/e/1FAIpQLSfSkpc7IV0B75mk0jnXB-sy3RMgUJke9tJKQBJ76lZaPHTonw/viewform?usp=header';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el formulario.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Conocer más'),
                ),
                  const SizedBox(height: 24), // Espacio antes del nuevo botón
                  // --- Nuevo Botón de "Solicitar Ayuda" ---
                  Center(
                    // <-- Este widget centra su hijo horizontalmente
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar a la pantalla de solicitud de ayuda
                        Navigator.of(context).pushNamed('/help');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Theme.of(context).primaryColor, // Usar el color primario del tema
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Solicitar Ayuda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // --- Fin Nuevo Botón ---
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Columna derecha
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // --- Supabase Image Call ---
                  Image.network(
                    imageUrl, // Use the generated image URL
                    height: 300,
                    fit: BoxFit.contain,
                    // Optional: Add errorBuilder for better debugging
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            'Error al cargar la imagen: image4.png\nHTTP request failed, statusCode: 400, URL: $imageUrl\nError: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                    // Optional: Add loadingBuilder for visual feedback
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _abrirPDF, // This will now open your Supabase PDF
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Leer más',
                        style: TextStyle(
                          color: Colors.orange,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}