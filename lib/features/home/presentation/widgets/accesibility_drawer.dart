// lib/widgets/accessibility_drawer.dart
import 'package:flutter/material.dart';

class AccessibilityDrawer extends StatelessWidget {
  final double fontSize;
  final bool highContrast;
  final bool darkMode;
  final bool underlineLinks;
  final bool readableFont;

  // Nuevas propiedades para los modos de color y contraste
  final bool grayscale;
  final bool negativeContrast;
  final bool lightBackground; // Si 'Fondo claro' es true, 'Fondo oscuro' es false y viceversa.

  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onUnderlineLinksChanged;
  final ValueChanged<bool> onReadableFontChanged;

  // Nuevos callbacks para los modos de color
  final ValueChanged<bool> onGrayscaleChanged;
  final ValueChanged<bool> onNegativeContrastChanged;
  final ValueChanged<bool> onLightBackgroundChanged;

  final VoidCallback onReset;
  final Color appBarColor; // Esta propiedad podría no ser necesaria directamente aquí
  final Color linkTextColor; // Esta propiedad podría no ser necesaria directamente aquí

  const AccessibilityDrawer({
    super.key,
    required this.fontSize,
    required this.highContrast,
    required this.darkMode,
    required this.underlineLinks,
    required this.readableFont,
    required this.onFontSizeChanged,
    required this.onHighContrastChanged,
    required this.onDarkModeChanged,
    required this.onUnderlineLinksChanged,
    required this.onReadableFontChanged,

    required this.grayscale,
    required this.onGrayscaleChanged,
    required this.negativeContrast,
    required this.onNegativeContrastChanged,
    required this.lightBackground,
    required this.onLightBackgroundChanged,

    required this.onReset,
    this.appBarColor = Colors.blue, // Valor por defecto si no se usa
    this.linkTextColor = Colors.blue, // Valor por defecto si no se usa
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los colores base para el texto del drawer, considerando el alto contraste
    Color defaultTextColor = highContrast ? Colors.white : Colors.black87;
    Color iconColor = const Color(0xFFF57C00); // Color naranja de los iconos de las opciones

    // Estilo base para los textos dentro del drawer
    TextStyle _textStyle(Color defaultColor) => TextStyle(
          fontSize: fontSize,
          fontFamily: readableFont ? 'Arial' : 'Roboto', // Considera cargar la fuente "Arial" si no está por defecto.
          color: defaultColor, // El color base del texto
          decoration: underlineLinks ? TextDecoration.underline : TextDecoration.none,
        );

    // Color de fondo del drawer según el modo claro/oscuro
    Color drawerBackgroundColor = lightBackground ? Colors.white : Colors.grey[800]!;
    // El color naranja para el encabezado del Drawer
    Color headerBackgroundColor = const Color(0xFFF57C00);

    return Drawer(
      // El Drawer por defecto no tiene esquinas redondeadas, lo que cumple tu requisito.
      child: Container(
        color: drawerBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero, // Elimina el padding superior por defecto del ListView
          children: [
            // Encabezado del Drawer: Fondo naranja con icono y texto blanco
            Container(
              height: 100,
              color: headerBackgroundColor, // Fondo naranja
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0, right: 16.0),
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  // Icono de accesibilidad blanco
                  Icon(Icons.accessibility_new, color: Colors.white, size: fontSize + 10),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Herramientas de accesibilidad',
                      style: _textStyle(Colors.white).copyWith(
                        fontSize: fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // El texto del encabezado siempre blanco
                        decoration: TextDecoration.none, // Asegura que el título no esté subrayado
                      ),
                      overflow: TextOverflow.ellipsis, // Para evitar que el texto se desborde
                    ),
                  ),
                ],
              ),
            ),
            // Opciones de texto (Aumentar/Disminuir)
            _buildAccessibilityOption(
              'Aumentar texto',
              Icons.zoom_in,
              () => onFontSizeChanged(fontSize + 1),
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildAccessibilityOption(
              'Disminuir texto',
              Icons.zoom_out,
              () => onFontSizeChanged(fontSize > 12 ? fontSize - 1 : 12),
              _textStyle(defaultTextColor),
              iconColor,
            ),
            // Opciones de contraste y color con Switches
            _buildSwitchOption(
              'Escala de grises',
              Icons.format_color_reset, // O un icono más apropiado si encuentras uno
              grayscale,
              onGrayscaleChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildSwitchOption(
              'Alto contraste',
              Icons.brightness_medium, // Icono sugerido para alto contraste
              highContrast,
              onHighContrastChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildSwitchOption(
              'Contraste negativo',
              Icons.invert_colors, // Icono para invertir colores/contraste
              negativeContrast,
              onNegativeContrastChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildSwitchOption(
              'Fondo claro',
              Icons.wb_sunny, // Icono para fondo claro
              lightBackground,
              onLightBackgroundChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildSwitchOption(
              'Subrayar enlaces',
              Icons.format_underline, // Icono para subrayar enlaces
              underlineLinks,
              onUnderlineLinksChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            _buildSwitchOption(
              'Fuente legible',
              Icons.font_download, // Icono para fuente
              readableFont,
              onReadableFontChanged,
              _textStyle(defaultTextColor),
              iconColor,
            ),
            const Divider(), // Separador visual
            // Opción de restablecer configuraciones
            _buildAccessibilityOption(
              'Restablecer',
              Icons.restart_alt,
              onReset,
              _textStyle(defaultTextColor),
              iconColor,
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para construir opciones con acción (tap)
  ListTile _buildAccessibilityOption(String title, IconData icon, VoidCallback onTap, TextStyle textStyle, Color iconColor) {
    return ListTile(
      title: Text(title, style: textStyle),
      leading: Icon(icon, color: iconColor),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  // Método auxiliar para construir opciones con un Switch
  Widget _buildSwitchOption(String title, IconData icon, bool value, ValueChanged<bool> onChanged, TextStyle textStyle, Color iconColor) {
    return ListTile(
      title: Text(title, style: textStyle),
      leading: Icon(icon, color: iconColor),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFF57C00), // Color del switch cuando está activo
      ),
      onTap: () => onChanged(!value), // Permite tocar toda la fila para cambiar el estado del switch
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}