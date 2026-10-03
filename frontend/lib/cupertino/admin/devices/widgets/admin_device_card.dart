// ============================================================
// admin_device_card.dart
// Card hiển thị 1 device trong danh sách Quản lý thiết bị.
// Bao gồm: tên device, owner, status, sensor readings.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

class AdminDeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AdminDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device['isOnline'] as bool? ?? false;
    final isPumping = device['isPumping'] as bool? ?? false;
    final temperature = device['temperature'] as num?;
    final humidity = device['humidity'] as num?;

    final statusColor = isOnline
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemRed;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================
            // Status dot + text + pump badge
            Row(
              children: [
                // Status indicator (dot xanh/đỏ)
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isOnline ? 'Đang hoạt động' : 'Mất kết nối',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Pump badge (chỉ hiện khi device đang phun)
                if (isPumping)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.cloud_fog_fill,
                          size: 10,
                          color: CupertinoColors.systemTeal,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Đang phun',
                          style: TextStyle(
                            color: CupertinoColors.systemTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ==================== DEVICE NAME ====================
            Text(
              device['name'] ?? 'Không tên',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),

            // ==================== OWNER ====================
            Row(
              children: [
                Icon(
                  CupertinoIcons.person_fill,
                  size: 11,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    device['ownerEmail'] ?? 'Chưa gán',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ==================== SENSOR READINGS ====================
            // Nhiệt độ + Độ ẩm + Chevron
            Row(
              children: [
                Expanded(
                  child: _ReadingChip(
                    icon: CupertinoIcons.thermometer,
                    value: temperature == null
                        ? '--°'
                        : '${temperature.toStringAsFixed(1)}°',
                    color: CupertinoColors.systemOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReadingChip(
                    icon: CupertinoIcons.drop_fill,
                    value: humidity == null
                        ? '--%'
                        : '${humidity.toStringAsFixed(0)}%',
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widget con: Chip hiển thị 1 giá trị cảm biến (nhiệt độ, độ ẩm)
// ============================================================
class _ReadingChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _ReadingChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}