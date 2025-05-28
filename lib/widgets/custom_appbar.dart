import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart'; // Importa el servicio de Supabase

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color linkTextColor; // Aunque se pasa, ajustaremos el color del texto del menú directamente a negro.

  CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.linkTextColor,
  });

  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sección izquierda: Logo y texto "Universidad Metropolitana"
          Row(
            children: [
              Image.network(
                _supabaseService.getPublicImageUrl('images', 'upload/logo.png'),
                height: 60, // ¡Ajuste aquí! Logo más grande.
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error al cargar logo.png', style: TextStyle(color: Colors.red));
                },
              ),
              const SizedBox(width: 12), // Espacio entre el logo y el texto
            ],
          ),

          // Sección central: Menú de navegación (solo visible en pantallas grandes)
          if (isLargeScreen)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ¡Ajuste aquí! Color de 'DDBE' y padding.
                    _buildAppBarMenuItem('DDBE', Colors.orange), // DDBE mantiene su color especial
                    _buildAppBarMenuItem('Noticias', Colors.black87), // Nombres de las vistas siempre en negro
                    _buildAppBarMenuItem('Cronograma', Colors.black87),
                    _buildAppBarMenuItem('Postúlate', Colors.black87),
                    _buildAppBarMenuItem('Contacto', Colors.black87),
                    _buildAppBarMenuItem('Más', Colors.black87, hasDropdown: true),
                  ],
                ),
              ),
            ),

          // Sección derecha: Iconos (notificaciones, mensajes, usuario, búsqueda)
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]), // Icono de campana (notificaciones)
                onPressed: () {
                  print('Icono de notificaciones presionado');
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[700]), // Icono de mensaje
                onPressed: () {
                  print('Icono de mensaje presionado');
                },
              ),
              IconButton(
                icon: Icon(Icons.account_circle, color: Colors.grey[700]), // Icono de perfil (usuario)
                onPressed: () {
                  print('Icono de usuario presionado');
                },
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[700]), // Icono de búsqueda
                onPressed: () {
                  print('Icono de búsqueda presionado');
                },
              ),
              // El icono de accesibilidad solo aparecerá si no es una pantalla grande,
              // ya que en pantallas grandes hay un botón flotante en el cuerpo de la página.
              if (!isLargeScreen)
                IconButton(
                  icon: Icon(Icons.accessibility_new, color: linkTextColor), // Mantiene linkTextColor para el de accesibilidad
                  onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir cada ítem del menú de la barra de navegación
  Widget _buildAppBarMenuItem(String text, Color color, {bool hasDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // ¡Ajuste aquí! Mayor separación entre palabras
      child: InkWell(
        onTap: () {
          print('Presionaste: $text');
        },
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: color, // El color viene como parámetro, ajustado arriba para ser negro.
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (hasDropdown) const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Aumenta la altura preferida para acomodar el logo más grande
}