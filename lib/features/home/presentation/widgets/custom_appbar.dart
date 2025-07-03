import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/services/chat_service.dart';
import 'dart:developer' as developer;

// Definición de colores del manual de marca
const Color kOrangeColor = Color(0xFFFF8200);
const Color kLightGrayColor = Color(0xFFD9D9D6);
const Color kDarkBlueColor = Color(0xFF003087);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String
  currentRoute; // Añadimos esta propiedad para saber la ruta actual
  final VoidCallback? onProfileIconPressed;
  final List<Widget>? actions; // <--- Agrega esto
  final bool isProfessor; // <--- Agrega esto

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.currentRoute, // Ahora es un parámetro requerido
    this.onProfileIconPressed,
    this.actions, // <--- Agrega esto
    this.isProfessor = false, // <--- Agrega esto
  });

  static final SupabaseService _supabaseService = SupabaseService();
  static final ChatService _chatService = ChatService();

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Inicio de sesión requerido'),
            content: const Text('Debes iniciar sesión para usar el chat.'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Ir a Login'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/login');
                },
              ),
            ],
          ),
    );
  }

  Future<void> _handleChatButtonPress(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showLoginRequiredDialog(context);
    } else {
      try {
        final chats = await _chatService.getUserChats();

        if (chats.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No tienes chats disponibles.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          developer.log(
            'User logged in but no chats available.',
            name: 'CustomAppBar',
          );
        } else {
          developer.log(
            'Chats available. Navigating to /chat',
            name: 'CustomAppBar',
          );
          Navigator.of(context).pushNamed('/chat');
        }
      } catch (e) {
        developer.log('Error getting chats: $e', name: 'CustomAppBarError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar chats: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo de la universidad
          GestureDetector(
            onTap: () {
              // Al presionar el logo, navega al home
              Navigator.of(context).pushNamed('/home');
            },
            child: Image.network(
              CustomAppBar._supabaseService.getPublicImageUrl(
                'images',
                'upload/logo.png',
              ),
              height: 40, // Logo más pequeño
              errorBuilder: (context, error, stackTrace) {
                developer.log(
                  'Error loading logo.png: $error',
                  name: 'CustomAppBar',
                );
                return const Text(
                  'Error loading logo.png',
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          if (isLargeScreen)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarMenuItem(context, 'DDBE', '/home'),
                    _buildAppBarMenuItem(context, 'Noticias', '/news'),
                    _buildAppBarMenuItem(context, 'Cronograma', '/calendar'),
                    _buildAppBarMenuItem(context, 'Postúlate', '/postulation'),
                    _buildAppBarMenuItem(context, 'Contacto', '/contact'),
                    _buildAppBarMenuItem(
                      context,
                      'Más',
                      '/more',
                      hasDropdown: true,
                    ),
                  ],
                ),
              ),
            ),

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
                onPressed: () => _handleChatButtonPress(context),
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
                  icon: Icon(
                    Icons.menu,
                    color: const Color.fromARGB(255, 59, 59, 59),
                  ), // Color de menú del manual de marca
                  onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // AppBar más finito, de 60.0

  Widget _buildAppBarMenuItem(
    BuildContext context,
    String text,
    String route, {
    bool hasDropdown = false,
  }) {
    final bool isCurrentRoute = (currentRoute == route);

    if (hasDropdown) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: PopupMenuButton<String>(
          child: Text(
            text,
            style: TextStyle(
              color:
                  isCurrentRoute
                      ? kOrangeColor
                      : const Color.fromARGB(255, 59, 59, 59),
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          onSelected: (value) {
            if (value == 'horas_culminadas') {
              final String? idEstudiante =
                  Supabase.instance.client.auth.currentUser?.id;
              if (idEstudiante != null) {
                Navigator.of(context).pushNamed(
                  '/horas_estudiante',
                  arguments: {'idEstudiante': idEstudiante},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo obtener el ID del estudiante.'),
                  ),
                );
              }
            } else if (value == 'dashboard_profesor') {
              final String? tuIdSupervisor =
                  Supabase.instance.client.auth.currentUser?.id;
              if (tuIdSupervisor != null) {
                Navigator.of(context).pushNamed(
                  '/dashboard',
                  arguments: {'id_supervisor': tuIdSupervisor},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo obtener el ID del profesor.'),
                  ),
                );
              }
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem<String>(
                  value: 'horas_culminadas',
                  child: Text('Ver horas culminadas'),
                ),
                if (isProfessor)
                  const PopupMenuItem<String>(
                    value: 'dashboard_profesor',
                    child: Text('Ir al Dashboard de Profesor'),
                  ),
                // Otros PopupMenuItem si quieres más opciones
              ],
        ),
      );
    }

    // Si no es dropdown, retorna el InkWell normal
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Text(
          text,
          style: TextStyle(
            color:
                isCurrentRoute
                    ? kOrangeColor
                    : const Color.fromARGB(255, 59, 59, 59),
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
