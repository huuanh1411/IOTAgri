// ============================================================
// ticket_list_tile.dart
// Card hiển thị 1 ticket trong danh sách Support Tickets.
// Bao gồm: subject, user, priority badge, status badge, thời gian.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

class TicketListTile extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TicketListTile({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] as String? ?? 'open';
    final priority = ticket['priority'] as String? ?? 'low';

    final statusColor = _statusColor(status);
    final priorityColor = _priorityColor(priority);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================
            // Priority badge + Status badge + Time
            Row(
              children: [
                // Priority badge
                _buildBadge(
                  context,
                  icon: _priorityIcon(priority),
                  label: _priorityLabel(priority),
                  color: priorityColor,
                ),
                const SizedBox(width: 6),
                // Status badge
                _buildBadge(
                  context,
                  icon: _statusIcon(status),
                  label: _statusLabel(status),
                  color: statusColor,
                ),
                const Spacer(),
                // Time
                Text(
                  _formatTimeAgo(ticket['createdAt']),
                  style: TextStyle(
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ==================== SUBJECT ====================
            Text(
              ticket['subject'] ?? 'Không có tiêu đề',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // ==================== LAST MESSAGE ====================
            Text(
              ticket['lastMessage'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // ==================== FOOTER ====================
            // User info + message count + chevron
            Row(
              children: [
                Icon(
                  CupertinoIcons.person_fill,
                  size: 12,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket['userName'] ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  size: 11,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
                const SizedBox(width: 3),
                Text(
                  '${ticket['messageCount'] ?? 0}',
                  style: TextStyle(
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return CupertinoColors.systemRed;
      case 'in_progress':
        return CupertinoColors.systemOrange;
      case 'closed':
        return AerogreenCupertinoTheme.aerogreenPrimary;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'open':
        return CupertinoIcons.exclamationmark_circle_fill;
      case 'in_progress':
        return CupertinoIcons.clock_fill;
      case 'closed':
        return CupertinoIcons.checkmark_circle_fill;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'MỚI';
      case 'in_progress':
        return 'ĐANG XỬ LÝ';
      case 'closed':
        return 'ĐÃ ĐÓNG';
      default:
        return 'KHÁC';
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return CupertinoColors.systemRed;
      case 'medium':
        return CupertinoColors.systemOrange;
      case 'low':
        return CupertinoColors.systemBlue;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return CupertinoIcons.arrow_up_circle_fill;
      case 'medium':
        return CupertinoIcons.minus_circle_fill;
      case 'low':
        return CupertinoIcons.arrow_down_circle_fill;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'CAO';
      case 'medium':
        return 'TRUNG';
      case 'low':
        return 'THẤP';
      default:
        return '--';
    }
  }

  String _formatTimeAgo(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}p trước';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h trước';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d trước';
      } else {
        return '${(diff.inDays / 7).floor()}w trước';
      }
    } catch (_) {
      return '';
    }
  }
}