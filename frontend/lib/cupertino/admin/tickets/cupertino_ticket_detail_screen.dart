// ============================================================
// cupertino_ticket_detail_screen.dart
// Màn hình chi tiết ticket (chat-style) — sẽ hoàn thiện ở Bước 7.4e.
// Hiện tại chỉ là placeholder để screen compile được.
// ============================================================

import 'package:flutter/cupertino.dart';

class CupertinoTicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const CupertinoTicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ticket['id'] ?? 'Ticket'),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.chat_bubble_2,
                  size: 80,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 20),
                Text(
                  ticket['subject'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'User: ${ticket['userName'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Chi tiết ticket sẽ được cập nhật ở Bước 7.4e.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}