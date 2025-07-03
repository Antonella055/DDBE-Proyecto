import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/accesibility_drawer.dart'; // Asegúrate de que esta importación sea correcta

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

  // ¡Nuevas variables de estado para los modos de color/contraste!
  bool _grayscale = false;
  bool _negativeContrast = false;
  bool _lightBackground = true; // Por defecto, fondo claro

  // Controladores para el formulario de contacto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient = supabase;

  // Estilos de texto adaptables
  TextStyle get _textStyle => TextStyle(
        fontSize: _fontSize,
        fontFamily: _readableFont ? 'Roboto' : 'Roboto', // Usar Roboto o Roboto Condensed
        color: _darkMode ? Colors.white : Colors.black, // Color adaptable al modo oscuro
        decoration:
            _underlineLinks ? TextDecoration.underline : TextDecoration.none,
      );

  Color get _backgroundColor => _darkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get _appBarColor =>
      _highContrast ? const Color(0xFFF57C00) : const Color(0xFF673AB7);

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
        SnackBar(
            content: Text('Por favor, completa todos los campos del formulario.',
                style: _textStyle.copyWith(color: Colors.white))),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Por favor, introduce un correo electrónico válido.',
                style: _textStyle.copyWith(color: Colors.white))),
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
          content: Text(
              '¡Mensaje enviado con éxito! Nos pondremos en contacto contigo pronto.',
              style: _textStyle.copyWith(color: Colors.white)),
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
          content: Text('Error al enviar el mensaje: $e',
              style: _textStyle.copyWith(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
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

  // --- MÉTODO _buildSectionTitle DEFINIDO AQUÍ ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: _textStyle.copyWith(
        fontSize: _fontSize + 8, // Ajustar tamaño para que sea un título
        fontWeight: FontWeight.bold,
        color: _darkMode ? Colors.white : Colors.black87, // Color adaptable
      ),
    );
  }

  // Método auxiliar para construir la información de contacto
  Widget _buildContactInfo(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _textStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: _darkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: _textStyle.copyWith(
            color: _darkMode ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Método auxiliar para construir campos de texto del formulario
  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: _textStyle, // Aplicar estilo de texto adaptable
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _textStyle.copyWith(
            color: _darkMode ? Colors.grey[400] : Colors.grey[600]), // Adaptable
        filled: true,
        fillColor: _darkMode ? Colors.grey[800] : Colors.grey[200], // Adaptable
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: _darkMode ? Colors.grey[700]! : Colors.grey[300]!), // Adaptable
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _appBarColor, width: 2), // Adaptable
        ),
      ),
    );
  }

  // Método auxiliar para construir ítems de Preguntas Frecuentes
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: _textStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: _darkMode ? Colors.white : Colors.black87, // Adaptable
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: _textStyle.copyWith(
              color: _darkMode ? Colors.white70 : Colors.black54, // Adaptable
            ),
          ),
        ),
      ],
    );
  }
  // --- FIN DE LA DEFINICIÓN DEL MÉTODO ---

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
        currentRoute: '/contact', // ¡Aquí se pasa la ruta actual!
        onProfileIconPressed: _onProfileIconPressed,
      ),
      body: Container(
        color: _backgroundColor, // Usar el color de fondo adaptable
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NUEVA SECCIÓN: Imagen Fija a pantalla completa (ancho) y mitad de alto
              Image.network(
                _supabaseService.getPublicImageUrl(
                    'images', 'upload/imagen3.jpg'), // Ruta corregida
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  color: _darkMode
                      ? Colors.grey[600]
                      : Colors.grey[300], // Color de error adaptable
                  child: Center(
                    child: Text(
                      'Error al cargar la imagen de contacto',
                      style: _textStyle.copyWith(
                          color: _darkMode
                              ? Colors.redAccent
                              : Colors.red), // Color adaptable
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    color: _darkMode
                        ? Colors.grey[600]
                        : Colors
                            .grey[200], // Fondo mientras carga adaptable
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _appBarColor), // Color del indicador adaptable
                      ),
                    ),
                  );
                },
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Text(
                  'Contáctanos',
                  style: _textStyle.copyWith(
                    fontSize: _fontSize + 12,
                    fontWeight: FontWeight.bold,
                    color: _darkMode
                        ? Colors.white
                        : Colors.black87, // Color adaptable
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sección de Información de Contacto
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
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
                padding:
                    EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Envíanos un mensaje'),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Nombre'),
                    const SizedBox(height: 16),
                    _buildTextField(_lastNameController, 'Apellido'),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Correo Electrónico',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_messageController, '¿En qué podemos ayudarte?',
                        maxLines: 5),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitContactForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _appBarColor, // Usar el color de la AppBar (adaptable)
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Enviar Mensaje',
                          style: _textStyle.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Sección de Preguntas Frecuentes
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isLargeScreen ? 120.0 : 32.0),
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
        onUnderlineLinksChanged: (value) =>
            setState(() => _underlineLinks = value),
        onReadableFontChanged: (value) =>
            setState(() => _readableFont = value),

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
            _darkMode ? Colors.white : Colors.blue, // Pasa el color de los enlaces (del getter)
      ),
    );
  }
}