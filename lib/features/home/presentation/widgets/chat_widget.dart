import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/services/chat_service.dart';
import 'dart:developer' as developer; // For logs

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedChatId;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // You can load initial chats here or wait for the FutureBuilder
    // For example, if you want the chat list to be displayed automatically when the chat opens:
    // _loadInitialChats(); // You'd need a function for this
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _loadChat(String chatId) async {
    developer.log('Loading chat with ID: $chatId', name: 'ChatWidget');
    setState(() {
      _selectedChatId = chatId;
      _messages = []; // Clear messages when changing chat
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty || _selectedChatId == null) {
      developer.log('Cannot send message: empty text or no chat selected', name: 'ChatWidget');
      return;
    }
    try {
      developer.log('Sending message: ${_messageController.text} to chat $_selectedChatId', name: 'ChatWidget');
      await _chatService.sendMessage(_selectedChatId!, _messageController.text);
      _messageController.clear();
    } catch (e) {
      developer.log('Error sending message: $e', name: 'ChatWidgetError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      developer.log('User not logged in, displaying login message', name: 'ChatWidget');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Debes iniciar sesión para usar el chat.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Ir a Login'),
            ),
          ],
        ),
      );
    }

    developer.log('User logged in. _selectedChatId: $_selectedChatId', name: 'ChatWidget');

    return Column( // This Column will be the body of the Scaffold in ChatPage
      children: [
        // The list of chats (if no chat selected) or the list of messages (if chat selected)
        if (_selectedChatId == null) // Show chat list if none is selected
          Expanded( // Ensures it occupies available space
            child: FutureBuilder<List<Map<String, dynamic>>>( // Specify FutureBuilder type
              future: _chatService.getUserChats(),
              builder: (context, snapshot) {
                developer.log('FutureBuilder for chats ConnectionState: ${snapshot.connectionState}', name: 'ChatWidget');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  developer.log('Error in FutureBuilder for chats: ${snapshot.error}', name: 'ChatWidgetError');
                  return Center(child: Text('Error al cargar chats: ${snapshot.error}'));
                }
                // <--- This `if` block is removed/modified from here, as the check is now in CustomAppBar
                // if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                //   developer.log('No data or empty chats', name: 'ChatWidget');
                //   return const Center(child: Text('No tienes chats disponibles.'));
                // }

                // The following line will now assume `snapshot.data` is not null and has data,
                // or handle the case where it might still be empty if the upstream check failed
                // to prevent navigating. For robustness, a simplified empty state is good.
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                     // This case *should* ideally be rare if the upstream check in CustomAppBar works.
                     // You could show a very simple message here, or even rely on the SnackBar
                     // from the button press if this is truly unexpected.
                     return const Center(child: Text('Error interno: No se encontraron chats.'));
                }

                developer.log('Chats loaded: ${snapshot.data!.length}', name: 'ChatWidget');
                final chats = snapshot.data!;
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final user1Data = chat['user1'] as Map<String, dynamic>;
                    final user2Data = chat['user2'] as Map<String, dynamic>;
                    final otherUser = user1Data['ID'] == user.id ? user2Data : user1Data;

                    return ListTile(
                      title: Text(otherUser['full_name'] ?? 'Usuario Desconocido'),
                      subtitle: Text(otherUser['user_type'] ?? 'Rol Desconocido'),
                      onTap: () => _loadChat(chat['id']),
                    );
                  },
                );
              },
            ),
          )
        else // If a chat is selected, show messages
          Expanded( // Ensures it occupies available space
            child: StreamBuilder<List<Map<String, dynamic>>>( // Specify StreamBuilder type
              stream: Supabase.instance.client
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('chat_id', _selectedChatId!)
                  .order('created_at'),
              builder: (context, snapshot) {
                developer.log('StreamBuilder for messages ConnectionState: ${snapshot.connectionState}', name: 'ChatWidget');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  developer.log('Error in StreamBuilder for messages: ${snapshot.error}', name: 'ChatWidgetError');
                  return Center(child: Text('Error al cargar mensajes: ${snapshot.error}'));
                }
                // If snapshot.data is null or empty, it means there are no messages yet.
                // We don't update _messages = snapshot.data! if there's no data to avoid null reference.
                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  _messages = []; // Ensure _messages is empty
                  developer.log('No data or empty messages', name: 'ChatWidget');
                  return const Center(child: Text('No hay mensajes en este chat.'));
                }
                _messages = snapshot.data!; // Update only if there's data
                developer.log('Messages loaded: ${_messages.length}', name: 'ChatWidget');

                return ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message['sender_id'] == user.id;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message['content']),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        // The text input field (only if a chat is selected)
        if (_selectedChatId != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
      ],
    );
  }
}