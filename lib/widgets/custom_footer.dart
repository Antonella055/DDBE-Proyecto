// lib/widgets/custom_footer.dart
import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart'; // Importa el servicio de Supabase

class CustomFooter extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;

  const CustomFooter({
    super.key,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Instancia del servicio de Supabase (se crea aquí porque el Footer también lo necesita)
    final SupabaseService _supabaseService = SupabaseService();

    // Determinar si la pantalla es lo suficientemente grande para el diseño de 3 columnas
    bool isLargeScreen = MediaQuery.of(context).size.width > 768; // Ajusta este valor según necesites

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0), // Aumenta el padding vertical
      child: isLargeScreen
          ? _buildLargeScreenFooter(_supabaseService)
          : _buildSmallScreenFooter(_supabaseService),
    );
  }

  // Footer para pantallas grandes (desktop)
  Widget _buildLargeScreenFooter(SupabaseService supabaseService) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido de las columnas arriba
      children: [
        // Columna izquierda: Logo y Copyright
        Expanded(
          flex: 2, // Le da más espacio al logo y copyright
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                supabaseService.getPublicImageUrl('images', 'upload/logo.png'), // Ruta del logo en Supabase
                height: 40, // Tamaño del logo
                errorBuilder: (context, error, stackTrace) {
                  return Text('Error al cargar logo', style: TextStyle(color: Colors.red, fontSize: 12));
                },
              ),
              const SizedBox(height: 10),
              Text(
                '© 2025 Universidad Metropolitana.\nTodos los derechos reservados.',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.0,
                  height: 1.5, // Espaciado de línea
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Espacio entre secciones

        // Columna de "Estudiantes"
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterTitle('Estudiantes'),
              const SizedBox(height: 10),
              _buildFooterLink('Constancia de Actividades'),
              _buildFooterLink('Registro de Actividades'),
              _buildFooterLink('Horas Acumuladas'),
              _buildFooterLink('Perfil'),
            ],
          ),
        ),
        const SizedBox(width: 20), // Espacio entre columnas

        // Columna de "Enlaces de Interés"
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterTitle('Enlaces de Interés'),
              const SizedBox(height: 10),
              _buildFooterLink('Postulación'),
              _buildFooterLink('Becas'), // Asumo que "Más" en tu imagen es "Becas" o un ítem similar
              _buildFooterLink('Noticias'),
              _buildFooterLink('Eventos'),
            ],
          ),
        ),
        const SizedBox(width: 20), // Espacio entre columnas

        // Columna de "Legal"
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterTitle('Legal'),
              const SizedBox(height: 10),
              _buildFooterLink('Política de Privacidad'),
              _buildFooterLink('Políticas de Cookies'),
              // _buildFooterLink('Términos de Servicio'), // Este no está en la imagen, si no lo necesitas, puedes quitarlo
            ],
          ),
        ),
      ],
    );
  }

  // Footer para pantallas pequeñas (móvil)
  Widget _buildSmallScreenFooter(SupabaseService supabaseService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos
      children: [
        Image.network(
          supabaseService.getPublicImageUrl('images', 'upload/unimet_logo.png'),
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Text('Error al cargar logo', style: TextStyle(color: Colors.red, fontSize: 12));
          },
        ),
        const SizedBox(height: 10),
        Text(
          '© 2025 Universidad Metropolitana.\nTodos los derechos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 14.0,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildFooterTitle('Estudiantes'),
        _buildFooterLink('Constancia de Actividades'),
        _buildFooterLink('Registro de Actividades'),
        _buildFooterLink('Horas Acumuladas'),
        _buildFooterLink('Perfil'),
        const SizedBox(height: 20),
        _buildFooterTitle('Enlaces de Interés'),
        _buildFooterLink('Postulación'),
        _buildFooterLink('Becas'),
        _buildFooterLink('Noticias'),
        _buildFooterLink('Eventos'),
        const SizedBox(height: 20),
        _buildFooterTitle('Legal'),
        _buildFooterLink('Política de Privacidad'),
        _buildFooterLink('Políticas de Cookies'),
        // _buildFooterLink('Términos de Servicio'),
      ],
    );
  }

  // Widget auxiliar para los títulos de las secciones del footer
  Widget _buildFooterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget auxiliar para los enlaces del footer
  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0), // Espacio entre enlaces
      child: InkWell(
        onTap: () {
          print('Enlace de footer presionado: $text');
          // TODO: Implementar la navegación para cada enlace
        },
        child: Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.8), // Un poco más claro que el título
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}