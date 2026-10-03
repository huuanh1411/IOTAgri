import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_theme.dart';

class AdminSystemHealthCard extends StatelessWidget {
  final Map<String, dynamic> systemHealth;

  const AdminSystemHealthCard({
    super.key,
    required this.systemHealth,
  });

  @override
  Widget build(BuildContext context) {
    final server = systemHealth['server'] as Map<String, dynamic>? ?? {};
    final mqtt = systemHealth['mqtt'] as Map<String, dynamic>? ?? {};
    final database = systemHealth['database'] as Map<String, dynamic>? ?? {};

    final serverStatus = server['status'] as String? ?? 'unknown';
    final mqttStatus = mqtt['status'] as String? ?? 'unknown';
    final dbStatus = database['status'] as String? ?? 'unknown';

    final allOnline = serverStatus == 'online' &&
        mqttStatus == 'online' &&
        dbStatus == 'online';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: allOnline
            ? AerogreenCupertinoTheme.aerogreenPrimary.withValues(alpha: 0.12)
            : CupertinoColors.systemRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: allOnline
                      ? AerogreenCupertinoTheme.aerogreenPrimary
                      : CupertinoColors.systemRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allOnline
                      ? CupertinoIcons.checkmark_shield_fill
                      : CupertinoIcons.exclamationmark_shield_fill,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allOnline ? 'Hệ thống ổn định' : 'Có sự cố hệ thống',
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      allOnline
                          ? 'Tất cả dịch vụ đang hoạt động bình thường.'
                          : 'Vui lòng kiểm tra các dịch vụ bên dưới.',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Server row
          _HealthRow(
            icon: CupertinoIcons.desktopcomputer,
            label: 'Server',
            status: serverStatus,
            detail: serverStatus == 'online'
                ? 'CPU ${(server['cpu'] as num?)?.toStringAsFixed(0) ?? '--'}% • '
                '${server['responseTimeMs'] ?? '--'}ms'
                : 'Không phản hồi',
          ),
          const SizedBox(height: 10),

          // MQTT row
          _HealthRow(
            icon: CupertinoIcons.antenna_radiowaves_left_right,
            label: 'MQTT Broker',
            status: mqttStatus,
            detail: mqttStatus == 'online'
                ? '${mqtt['connections'] ?? '--'} kết nối • '
                '${mqtt['messagesPerSec'] ?? '--'} msg/s'
                : 'Không phản hồi',
          ),
          const SizedBox(height: 10),

          // Database row
          _HealthRow(
            icon: CupertinoIcons.archivebox_fill,
            label: 'Database',
            status: dbStatus,
            detail: dbStatus == 'online'
                ? '${database['sizeGb'] ?? '--'} GB • '
                '${database['responseTimeMs'] ?? '--'}ms'
                : 'Không phản hồi',
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final String detail;

  const _HealthRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = status == 'online';
    final statusColor = isOnline
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemRed;

    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                detail,
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}