import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import 'chat_provider.dart';
import 'widgets/chat_list_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: convAsync.when(
        loading: () => const LoadingShimmer(),
        error: (_, __) => const ErrorStateWidget(),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Nenhuma conversa ainda',
              subtitle: 'Entre em contato com o anfitrião de uma hospedagem',
            );
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) => ChatListTile(
              conversation: conversations[i],
              onTap: () => context.go(
                  '/inbox/chat/${conversations[i].id}',
                  extra: conversations[i]),
            ),
          );
        },
      ),
    );
  }
}
