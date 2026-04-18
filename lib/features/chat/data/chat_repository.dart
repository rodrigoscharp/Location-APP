import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/conversation.dart';
import '../domain/message.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  /// Real-time stream of messages for a conversation
  Stream<List<Message>> watchMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.map(Message.fromJson).toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
    });
  }

  Future<List<Conversation>> getConversations(String userId) async {
    final data = await _client
        .from('conversations')
        .select('''
          *,
          listings(title),
          profiles(id, full_name, avatar_url)
        ''')
        .or('guest_id.eq.$userId,host_id.eq.$userId')
        .order('created_at', ascending: false);

    return (data as List)
        .map((j) => Conversation.fromJson(j, userId))
        .toList();
  }

  Future<Conversation?> findOrCreateConversation({
    required String listingId,
    required String guestId,
    required String hostId,
  }) async {
    // Try to find existing
    final existing = await _client
        .from('conversations')
        .select()
        .eq('listing_id', listingId)
        .eq('guest_id', guestId)
        .eq('host_id', hostId)
        .maybeSingle();

    if (existing != null) {
      return Conversation(
        id: existing['id'],
        listingId: listingId,
        guestId: guestId,
        hostId: hostId,
        createdAt: DateTime.parse(existing['created_at']),
      );
    }

    // Create new
    final created = await _client
        .from('conversations')
        .insert({
          'listing_id': listingId,
          'guest_id': guestId,
          'host_id': hostId,
        })
        .select()
        .single();

    return Conversation(
      id: created['id'],
      listingId: listingId,
      guestId: guestId,
      hostId: hostId,
      createdAt: DateTime.parse(created['created_at']),
    );
  }
}
