import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/conversation.dart';

class ChatListTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.lightGray,
        backgroundImage: conversation.otherUserAvatar != null
            ? CachedNetworkImageProvider(conversation.otherUserAvatar!)
            : null,
        child: conversation.otherUserAvatar == null
            ? const Icon(Icons.person_outline, color: AppColors.warmGray)
            : null,
      ),
      title: Text(
        conversation.otherUserName ?? 'Anfitrião',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        conversation.listingTitle ?? 'Hospedagem',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.warmGray, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGray),
    );
  }
}
