// lib/features/contact/presentation/pages/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/services/supabase_service.dart'; // Asegúrate de que esta importación sea correcta
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // Estados para la accesibilidad
  double _fontSize = 16.0;
  bool _highContrast = false;
  bool _darkMode = false;
  bool _underlineLinks = false;
  bool _readableFont = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controladores para el formulario de contacto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // MANTENEMOS SupabaseService aquí porque la vamos a usar para la imagen
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient = supabase; // Get the client from main.dart

  // Estilos de texto adaptables
  TextStyle get _textStyle => TextStyle(
        fontSize: _fontSize,
        fontFamily: _readableFont ? 'Arial' : 'Roboto',
        color: _darkMode ? Colors.white : Colors.black,
        decoration: _underlineLinks ? TextDecoration.underline : TextDecoration.none,
      );

  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get _appBarColor => _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);
  Color get _linkTextColor => _highContrast ? Colors.black : Colors.white;

  // Método para manejar la acción del icono de perfil
  void _onProfileIconPressed() {
    if (_supabaseClient.auth.currentUser == null) {
      Navigator.of(context).pushNamed('/login');
    } else {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  // Método para enviar el formulario de contacto
  void _submitContactForm() async {
    final String name = _nameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String email = _emailController.text.trim();
    final String message = _messageController.text.trim();

    // Validaciones básicas
    if (name.isEmpty || lastName.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos del formulario.', style: _textStyle.copyWith(color: Colors.white))),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, introduce un correo electrónico válido.', style: _textStyle.copyWith(color: Colors.white))),
      );
      return;
    }

    try {
      // TODO: Implementar la lógica para enviar los datos a Supabase
      // Si usas Supabase, aquí iría tu código de inserción de datos en la tabla 'contact_messages'
      // Ejemplo:
      // await _supabaseClient.from('contact_messages').insert({
      //   'name': name,
      //   'last_name': lastName,
      //   'email': email,
      //   'message': message,
      //   'created_at': DateTime.now().toIso8601String(),
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Mensaje enviado con éxito! Nos pondremos en contacto contigo pronto.', style: _textStyle.copyWith(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      // Limpiar los campos del formulario
      _nameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _messageController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el mensaje: $e', style: _textStyle.copyWith(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
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
              // NUEVA SECCIÓN: Imagen Fija a pantalla completa (ancho) y mitad de alto
              // Se eliminó el Center y el Padding que causaban los márgenes
              Image.network(
                // Ajusta la ruta a tu bucket y nombre de archivo exactos
                _supabaseService.getPublicImageUrl('images', 'upload/imagen3.jpg'), // Ruta corregida
                width: MediaQuery.of(context).size.width, // Ocupa todo el ancho de la pantalla
                height: MediaQuery.of(context).size.height / 2, // Ocupa la mitad de la altura de la pantalla
                fit: BoxFit.cover, // Para que la imagen cubra el espacio sin distorsionarse
                errorBuilder: (context, error, stackTrace) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      'Error al cargar la imagen de contacto',
                      style: _textStyle.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
              // const SizedBox(height: 24), // Quita este espacio si quieres que el siguiente contenido esté justo debajo de la imagen
                                          // O déjalo si quieres un pequeño espacio.

              // Sección de Título "Contáctanos" (movido debajo de la imagen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Text(
                  'Contáctanos',
                  style: _textStyle.copyWith(
                    fontSize: _fontSize + 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // Sección de Información de Contacto
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Información de Contacto'),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      'Cledy Parejo, directora.',
                      'directora.ddbe@unimet.edu.ve / (0212)-240. 32.70',
                    ),
                    _buildContactInfo(
                      'Becas:',
                      'becas@unimet.edu.ve / (0212)-240. 32.84 (Recepción)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Sección de Formulario de Contacto
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Envíanos un mensaje'),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Nombre'),
                    const SizedBox(height: 16),
                    _buildTextField(_lastNameController, 'Apellido'),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_messageController, '¿En qué podemos ayudarte?', maxLines: 5),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitContactForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Enviar Mensaje',
                          style: _textStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Sección de Preguntas Frecuentes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Preguntas Frecuentes'),
                    const SizedBox(height: 24),
                    _buildFAQItem(
                      '¿Cuáles son los horarios de atención?',
                      'Nuestra oficina está abierta de lunes a viernes, de 8:00 AM a 4:00 PM.',
                    ),
                    _buildFAQItem(
                      '¿Cómo solicito una beca?',
                      'Para solicitar una beca, visita nuestra sección de Becas en el menú principal y sigue las instrucciones detalladas allí.',
                    ),
                    _buildFAQItem(
                      '¿Ofrecen asesoramiento psicológico?',
                      'Sí, contamos con un equipo de profesionales que ofrecen asesoramiento psicológico. Puedes solicitar una cita a través de nuestro correo o teléfono de contacto.',
                    ),
                    _buildFAQItem(
                      '¿Dónde puedo encontrar información sobre eventos estudiantiles?',
                      'Toda la información sobre eventos se publica en la sección de Noticias y Eventos de nuestra página web y en nuestras redes sociales.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

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
        fontSize: _fontSize + 8,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildContactInfo(String title, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _textStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: _fontSize + 2,
            color: Colors.black87,
          ),
        ),
        Text(
          details,
          style: _textStyle.copyWith(
            fontSize: _fontSize,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: _textStyle,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _textStyle.copyWith(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        fillColor: _darkMode ? Colors.grey[800] : Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: _darkMode ? Colors.grey[800] : Colors.white,
      child: ExpansionTile(
        title: Text(
          question,
          style: _textStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: _darkMode ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: _textStyle.copyWith(
                color: _darkMode ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}