import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_theme.dart';

class AdminQuickStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminQuickStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: CupertinoIcons.person_2_fill,
            label: 'Users',
            value: '${stats['totalUsers'] ?? 0}',
            subValue: '${stats['totalUsers'] ?? 0} active',
            color: CupertinoColors.systemBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: CupertinoIcons.device_phone_portrait,
            label: 'Devices',
            value: '${stats['totalDevices'] ?? 0}',
            subValue: '${stats['onlineDevices'] ?? 0} online',
            color: AerogreenCupertinoTheme.aerogreenPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: CupertinoIcons.exclamationmark_triangle_fill,
            label: 'Alerts',
            value: '${stats['totalAlerts'] ?? 0}',
            subValue: '${stats['unresolvedAlerts'] ?? 0} chưa xử lý',
            color: CupertinoColors.systemOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: CupertinoIcons.chat_bubble_2_fill,
            label: 'Tickets',
            value: '${stats['openTickets'] ?? 0}',
            subValue: 'đang mở',
            color: CupertinoColors.systemPurple,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}