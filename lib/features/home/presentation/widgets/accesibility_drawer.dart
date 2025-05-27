// lib/widgets/accessibility_drawer.dart
import 'package:flutter/material.dart';

class AccessibilityDrawer extends StatelessWidget {
  final double fontSize;
  final bool highContrast;
  final bool darkMode;
  final bool underlineLinks;
  final bool readableFont;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onUnderlineLinksChanged;
  final ValueChanged<bool> onReadableFontChanged;
  final VoidCallback onReset;
  final Color appBarColor;
  final Color linkTextColor;

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
    required this.onReset,
    required this.appBarColor,
    required this.linkTextColor,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle(Color defaultColor) => TextStyle(
      fontSize: fontSize,
      fontFamily: readableFont ? 'Arial' : 'Roboto',
      color: darkMode ? Colors.white : defaultColor,
      decoration: underlineLinks ? TextDecoration.underline : TextDecoration.none,
    );

    return Drawer(
      child: Container(
        color: darkMode ? Colors.grey[800] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              color: const Color(0xFFF57C00),
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              alignment: Alignment.bottomLeft,
              child: Text(
                'Opciones de Accesibilidad',
                style: _textStyle(Colors.white).copyWith(
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _buildAccessibilityOption(
              'Aumentar texto',
              Icons.zoom_in,
              () => onFontSizeChanged(fontSize + 1),
              _textStyle(Colors.black87),
            ),
            _buildAccessibilityOption(
              'Disminuir texto',
              Icons.zoom_out,
              () => onFontSizeChanged(fontSize > 12 ? fontSize - 1 : 12),
              _textStyle(Colors.black87),
            ),
            SwitchListTile(
              title: Text('Alto contraste', style: _textStyle(Colors.black87)),
              value: highContrast,
              onChanged: onHighContrastChanged,
              activeColor: const Color(0xFFF57C00),
            ),
            SwitchListTile(
              title: Text('Modo oscuro', style: _textStyle(Colors.black87)),
              value: darkMode,
              onChanged: onDarkModeChanged,
              activeColor: const Color(0xFFF57C00),
            ),
            SwitchListTile(
              title: Text('Subrayar enlaces', style: _textStyle(Colors.black87)),
              value: underlineLinks,
              onChanged: onUnderlineLinksChanged,
              activeColor: const Color(0xFFF57C00),
            ),
            SwitchListTile(
              title: Text('Fuente legible', style: _textStyle(Colors.black87)),
              value: readableFont,
              onChanged: onReadableFontChanged,
              activeColor: const Color(0xFFF57C00),
            ),
            const Divider(),
            _buildAccessibilityOption(
              'Restablecer',
              Icons.restart_alt,
              onReset,
              _textStyle(Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildAccessibilityOption(String title, IconData icon, VoidCallback onTap, TextStyle textStyle) {
    return ListTile(
      title: Text(title, style: textStyle),
      leading: Icon(icon, color: const Color(0xFFF57C00)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}