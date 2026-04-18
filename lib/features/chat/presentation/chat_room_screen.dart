import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.charcoal, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anfitrião',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.lightGray),
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
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            color: AppColors.mediumGray, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Seja o primeiro a enviar uma mensagem!',
                          style: GoogleFonts.dmSans(
                            color: AppColors.warmGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
