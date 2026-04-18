import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 60 : 0,
          right: isMine ? 0 : 60,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.coral : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine ? AppColors.white : AppColors.charcoal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(message.createdAt.toLocal()),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.warmGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
