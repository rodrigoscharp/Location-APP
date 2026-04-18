import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/chat_repository.dart';
import '../domain/conversation.dart';
import '../domain/message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(chatRepositoryProvider).getConversations(user.id);
});

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});
