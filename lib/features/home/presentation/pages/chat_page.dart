import 'package:flutter/material.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/chat_widget.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ChatWidget(),
    );
  }
}