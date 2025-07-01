import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener chats del usuario actual
  Future<List<Map<String, dynamic>>> getUserChats() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return []; // No hay usuario logueado, no hay chats
    }

    // Obtener el perfil del usuario actual para conocer su rol (user_type)
    final currentProfile = await _supabase
        .from('profiles')
        .select('user_type')
        .eq('ID', currentUser.id)
        .single();
    final currentUserRole = currentProfile['user_type'] as String;

    // Consulta para chats donde el usuario actual es user1_id o user2_id.
    // **CORRECCIÓN:** Cambiado 'name' a 'full_name'
    final chatsResponse = await _supabase
        .from('chats')
        .select('*, user1:user1_id(ID, full_name, user_type), user2:user2_id(ID, full_name, user_type)') // <--- CAMBIO AQUÍ
        .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}');

    final List<Map<String, dynamic>> allChats = [];

    for (var chat in chatsResponse) {
      final user1Data = chat['user1'] as Map<String, dynamic>;
      final user2Data = chat['user2'] as Map<String, dynamic>;

      // Determinar el "otro" usuario en el chat y acceder a sus datos
      final otherUser = user1Data['ID'] == currentUser.id ? user2Data : user1Data;
      final otherUserRole = otherUser['user_type'] as String;

      bool canSeeChat = false;

      // Reglas de visibilidad de chat
      switch (currentUserRole) {
        case 'Student':
          if ((otherUserRole == 'Professor' || otherUserRole == 'Admin')) {
            canSeeChat = true;
          }
          break;
        case 'Professor':
          if ((otherUserRole == 'Student' || otherUserRole == 'Admin')) {
            canSeeChat = true;
          }
          break;
        case 'Admin':
          if (otherUserRole == 'Student' || otherUserRole == 'Professor') {
            canSeeChat = true;
          }
          break;
        default:
          canSeeChat = false;
      }

      if (canSeeChat) {
        allChats.add(chat);
      }
    }
    return allChats;
  }

  // Obtener mensajes de un chat
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    return await _supabase
        .from('messages')
        // **CORRECCIÓN:** Cambiado 'name' a 'full_name'
        .select('*, sender:sender_id(ID, full_name, user_type)') // <--- CAMBIO AQUÍ
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
  }

  // Enviar mensaje
  Future<void> sendMessage(String chatId, String content) async {
    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': _supabase.auth.currentUser?.id,
      'content': content,
    });
  }

  // Crear chat
  Future<String> createChat(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final existingChats = await _supabase
        .from('chats')
        .select('id')
        .or('and(user1_id.eq.$userId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$userId)')
        .maybeSingle();

    if (existingChats != null) {
      return existingChats['id'] as String;
    }

    final newChat = await _supabase
        .from('chats')
        .insert({'user1_id': userId, 'user2_id': otherUserId})
        .select('id')
        .single();

    return newChat['id'] as String;
  }

  Future<void> joinChat(String chatId) async {
    // Implementación de joinChat si es necesaria
  }
}