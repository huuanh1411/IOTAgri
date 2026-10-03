// ============================================================
// user_filter_chips.dart
// Thanh filter chips cho màn hình Quản lý người dùng.
// Cho phép lọc user theo: All / Active / Locked / Admin.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

enum UserFilter {
  all,
  active,
  locked,
  admin,
}

class UserFilterChips extends StatelessWidget {
  final UserFilter selected;
  final ValueChanged<UserFilter> onChanged;
  final Map<UserFilter, int> counts;

  const UserFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip(
            context,
            filter: UserFilter.all,
            label: 'Tất cả',
            count: counts[UserFilter.all] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: UserFilter.active,
            label: 'Hoạt động',
            count: counts[UserFilter.active] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: UserFilter.locked,
            label: 'Đã khóa',
            count: counts[UserFilter.locked] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: UserFilter.admin,
            label: 'Admin',
            count: counts[UserFilter.admin] ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, {
        required UserFilter filter,
        required String label,
        required int count,
      }) {
    final isSelected = selected == filter;
    final color = isSelected
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.secondaryLabel.resolveFrom(context);

    return GestureDetector(
      onTap: () => onChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AerogreenCupertinoTheme.aerogreenPrimary
              : CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.label.resolveFrom(context),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.white.withValues(alpha: 0.25)
                    : CupertinoColors.tertiaryLabel
                    .resolveFrom(context)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? CupertinoColors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}