import 'package:flutter/material.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/chat_widget.dart'; // Importa tu ChatWidget
// Removed: import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';
// Removed: import 'package:ayudantia_software/features/home/presentation/widgets/custom_footer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asigna la GlobalKey al Scaffold
      // Removed: appBar: CustomAppBar(...)
      body: const ChatWidget(), // Tu contenido principal del chat
      // Removed: bottomNavigationBar: CustomFooter(...)
      // Si usas un Drawer o EndDrawer, irían aquí
      // endDrawer: CustomEndDrawer(), // Si tienes un drawer lateral para pantallas pequeñas
    );
  }
}