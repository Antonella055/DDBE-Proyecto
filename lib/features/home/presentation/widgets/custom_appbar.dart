import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart'; // Importa el servicio de Supabase
import 'dart:developer' as developer; // Importar para usar developer.log

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color linkTextColor;
  final VoidCallback? onProfileIconPressed; // NEW: Callback para el icono de perfil

  CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.linkTextColor,
    this.onProfileIconPressed, // NEW: Añade al constructor
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
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  developer.log('Error al cargar logo.png: $error', name: 'CustomAppBar'); // Usando developer.log
                  return const Text('Error al cargar logo.png', style: TextStyle(color: Colors.red));
                },
              ),
              const SizedBox(width: 12),
              // Aquí podrías tener el texto de la universidad si lo tuvieras antes
            ],
          ),

          // Sección central: Menú de navegación (solo visible en pantallas grandes)
          if (isLargeScreen)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarMenuItem(context, 'DDBE', Colors.orange, route: '/home'), // Ejemplo de ruta
                    _buildAppBarMenuItem(context, 'Noticias', Colors.black87, route: '/news'), // Ejemplo de ruta
                    _buildAppBarMenuItem(context, 'Cronograma', Colors.black87, route: '/schedule'), // Ejemplo de ruta
                    _buildAppBarMenuItem(context, 'Postúlate', Colors.black87, route: '/apply'), // Ejemplo de ruta
                    _buildAppBarMenuItem(context, 'Contacto', Colors.black87, route: '/contact'), // ¡Aquí está la navegación a Contacto!
                    _buildAppBarMenuItem(context, 'Más', Colors.black87, hasDropdown: true, route: '/more'), // Ejemplo de ruta
                  ],
                ),
              ),
            ),

          // Sección derecha: Iconos (notificaciones, mensajes, usuario, búsqueda)
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                onPressed: () {
                  developer.log('Icono de notificaciones presionado', name: 'CustomAppBar'); // Usando developer.log
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[700]),
                onPressed: () {
                  developer.log('Icono de mensaje presionado', name: 'CustomAppBar'); // Usando developer.log
                },
              ),
              // NEW: Icono de perfil de usuario con el callback
              if (onProfileIconPressed != null) // Solo muestra si se proporciona el callback
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.grey[700]),
                  onPressed: onProfileIconPressed, // Usa el callback pasado
                ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[700]),
                onPressed: () {
                  developer.log('Icono de búsqueda presionado', name: 'CustomAppBar'); // Usando developer.log
                },
              ),
              if (!isLargeScreen)
                IconButton(
                  icon: Icon(Icons.accessibility_new, color: linkTextColor),
                  onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  // Widget auxiliar para construir cada ítem del menú de la barra de navegación
  Widget _buildAppBarMenuItem(BuildContext context, String text, Color color, {bool hasDropdown = false, String? route}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          developer.log('Presionaste: $text', name: 'CustomAppBar'); // Usando developer.log
          if (route != null) {
            // Verifica si la ruta no es nula antes de navegar
            Navigator.of(context).pushNamed(route);
          }
        },
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: color,
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
}