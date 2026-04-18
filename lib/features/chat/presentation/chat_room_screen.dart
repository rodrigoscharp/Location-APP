import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import 'chat_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ChatRoomScreen extends ConsumerWidget {
  final String conversationId;

  const ChatRoomScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(conversationId));
    final currentUser = ref.watch(currentUserProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Conversa',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.coral),
              ),
              error: (_, __) =>
                  const Center(child: Text('Erro ao carregar mensagens')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Seja o primeiro a enviar uma mensagem!',
                      style: TextStyle(color: AppColors.warmGray),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[messages.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: MessageBubble(
                        message: msg,
                        isMine: msg.senderId == currentUser?.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: (text) async {
              if (currentUser == null) return;
              await chatRepo.sendMessage(
                conversationId: conversationId,
                senderId: currentUser.id,
                content: text,
              );
            },
          ),
        ],
      ),
    );
  }
}
