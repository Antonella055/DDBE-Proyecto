import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/features/home/presentation/pages/horas_culminadas_screen.dart'; // Import correcto
import 'dart:developer' as developer;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color linkTextColor;
  final VoidCallback? onProfileIconPressed;

  CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.linkTextColor,
    this.onProfileIconPressed,
  });

  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sección izquierda: Logo
          Row(
            children: [
              Image.network(
                _supabaseService.getPublicImageUrl('images', 'upload/logo.png'),
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  developer.log(
                    'Error al cargar logo.png: $error',
                    name: 'CustomAppBar',
                  );
                  return const Text(
                    'Error al cargar logo.png',
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Sección central: Menú de navegación (solo visible en pantallas grandes)
          if (isLargeScreen)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarMenuItem(
                      context,
                      'DDBE',
                      Colors.orange,
                      route: '/home',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Noticias',
                      Colors.black87,
                      route: '/news',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Cronograma',
                      Colors.black87,
                      route: '/calendar',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Postúlate',
                      Colors.black87,
                      route: '/apply',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Contacto',
                      Colors.black87,
                      route: '/contact',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Dashboard',
                      const Color.fromARGB(255, 0, 0, 0),
                      route: '/dashboard',
                    ),
                    _buildAppBarMenuItem(
                      context,
                      'Más',
                      Colors.black87,
                      hasDropdown: true,
                      route: '/more',
                    ),
                  ],
                ),
              ),
            ),

          // Sección derecha: Iconos
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                onPressed: () {
                  developer.log(
                    'Icono de notificaciones presionado',
                    name: 'CustomAppBar',
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[700]),
                onPressed: () {
                  developer.log(
                    'Icono de mensaje presionado',
                    name: 'CustomAppBar',
                  );
                },
              ),
              // BOTÓN HORAS CULMINADAS
              IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.deepPurple,
                ),
                tooltip: 'Horas Culminadas',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HorasCulminadasScreen(),
                    ),
                  );
                },
              ),
              if (onProfileIconPressed != null)
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.grey[700]),
                  onPressed: onProfileIconPressed,
                ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[700]),
                onPressed: () {
                  developer.log(
                    'Icono de búsqueda presionado',
                    name: 'CustomAppBar',
                  );
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
  Widget _buildAppBarMenuItem(
    BuildContext context,
    String text,
    Color color, {
    bool hasDropdown = false,
    String? route,
    Map<String, dynamic>? arguments,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          developer.log('Presionaste: $text', name: 'CustomAppBar');
          if (route != null) {
            Navigator.of(context).pushNamed(route, arguments: arguments);
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
            if (hasDropdown)
              const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
