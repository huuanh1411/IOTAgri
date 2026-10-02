// ============================================================
// user_list_tile.dart
// Card hiển thị 1 user trong danh sách Quản lý người dùng.
// Bao gồm: avatar, tên, email, role badge, status, số devices.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const UserListTile({
    super.key,
    required this.user,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'user';
    final isAdmin = role == 'admin';
    final isLocked = user['isLocked'] as bool? ?? false;
    final deviceCount = user['deviceCount'] as int? ?? 0;

    // Màu avatar dựa trên role
    final avatarColor = isAdmin
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemBlue;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ==================== AVATAR ====================
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: avatarColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isAdmin
                      ? CupertinoIcons.shield_lefthalf_fill
                      : CupertinoIcons.person_fill,
                  color: avatarColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ==================== INFO ====================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên + badge admin (nếu có)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user['fullName'] ?? 'Không tên',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AerogreenCupertinoTheme.aerogreenPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Email
                  Text(
                    user['email'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Row: status + device count
                  Row(
                    children: [
                      // Status badge (Active / Locked)
                      _StatusBadge(isLocked: isLocked),
                      const SizedBox(width: 8),
                      // Device count
                      Icon(
                        CupertinoIcons.device_phone_portrait,
                        size: 12,
                        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$deviceCount thiết bị',
                        style: TextStyle(
                          color:
                          CupertinoColors.tertiaryLabel.resolveFrom(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================== CHEVRON ====================
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widget con: Badge trạng thái (Active / Locked)
// ============================================================
class _StatusBadge extends StatelessWidget {
  final bool isLocked;

  const _StatusBadge({required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final color = isLocked
        ? CupertinoColors.systemRed
        : AerogreenCupertinoTheme.aerogreenPrimary;
    final label = isLocked ? 'Đã khóa' : 'Hoạt động';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked
                ? CupertinoIcons.lock_fill
                : CupertinoIcons.checkmark_circle_fill,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}