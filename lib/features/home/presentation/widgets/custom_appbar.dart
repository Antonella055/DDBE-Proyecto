import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:ayudantia_software/services/chat_service.dart'; // <--- Make sure this import is here
import 'dart:developer' as developer;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color linkTextColor;
  final VoidCallback? onProfileIconPressed;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.linkTextColor,
    this.onProfileIconPressed,
  });

  // Hacemos las instancias de SupabaseService y ChatService estáticas
  static final SupabaseService _supabaseService = SupabaseService();
  static final ChatService _chatService = ChatService(); // <--- This line is new/modified

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  // New method to handle the chat button press
  Future<void> _handleChatButtonPress(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showLoginRequiredDialog(context);
    } else {
      try {
        final chats = await _chatService.getUserChats(); // Attempt to get chats

        if (chats.isEmpty) {
          // If no chats, show a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes chats disponibles.', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2), // Duration of the message
            ),
          );
          developer.log('User logged in but no chats available.', name: 'CustomAppBar');
        } else {
          // If chats exist, navigate to the chat page
          developer.log('Chats available. Navigating to /chat', name: 'CustomAppBar');
          Navigator.of(context).pushNamed('/chat');
        }
      } catch (e) {
        // Handle any errors when loading chats
        developer.log('Error getting chats: $e', name: 'CustomAppBarError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar chats: $e', style: const TextStyle(color: Colors.white)),
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
          Row(
            children: [
              Image.network(
                CustomAppBar._supabaseService.getPublicImageUrl('images', 'upload/logo.png'),
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  developer.log('Error loading logo.png: $error', name: 'CustomAppBar');
                  return const Text('Error loading logo.png', style: TextStyle(color: Colors.red));
                },
              ),
              const SizedBox(width: 12),
            ],
          ),

          if (isLargeScreen)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarMenuItem(context, 'DDBE', Colors.orange, route: '/home'),
                    _buildAppBarMenuItem(context, 'Noticias', Colors.black87, route: '/news'),
                    _buildAppBarMenuItem(context, 'Cronograma', Colors.black87, route: '/calendar'),
                    _buildAppBarMenuItem(context, 'Postúlate', Colors.black87, route: '/postulation'),
                    _buildAppBarMenuItem(context, 'Contacto', Colors.black87, route: '/contact'),
                    _buildAppBarMenuItem(context, 'Más', Colors.black87, hasDropdown: true, route: '/more'),
                  ],
                ),
              ),
            ),

          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                onPressed: () {
                  developer.log('Notifications icon pressed', name: 'CustomAppBar');
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[700]),
                onPressed: () => _handleChatButtonPress(context), // <--- This line is modified
              ),
              if (onProfileIconPressed != null)
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.grey[700]),
                  onPressed: onProfileIconPressed,
                ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[700]),
                onPressed: () {
                  developer.log('Search icon pressed', name: 'CustomAppBar');
                },
              ),
              if (!isLargeScreen)
                IconButton(
                  icon: Icon(Icons.menu, color: linkTextColor),
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

  Widget _buildAppBarMenuItem(BuildContext context, String text, Color color, {bool hasDropdown = false, String? route}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          developer.log('You pressed: $text', name: 'CustomAppBar');
          if (route != null) {
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