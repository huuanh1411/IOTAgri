// ============================================================
// device_filter_chips.dart
// Thanh filter chips cho màn hình Quản lý thiết bị.
// Cho phép lọc device theo: All / Online / Offline / Pumping.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

enum DeviceFilter {
  all,
  online,
  offline,
  pumping,
}

class DeviceFilterChips extends StatelessWidget {
  final DeviceFilter selected;
  final ValueChanged<DeviceFilter> onChanged;
  final Map<DeviceFilter, int> counts;

  const DeviceFilterChips({
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
            filter: DeviceFilter.all,
            label: 'Tất cả',
            count: counts[DeviceFilter.all] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: DeviceFilter.online,
            label: 'Online',
            count: counts[DeviceFilter.online] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: DeviceFilter.offline,
            label: 'Offline',
            count: counts[DeviceFilter.offline] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: DeviceFilter.pumping,
            label: 'Đang phun',
            count: counts[DeviceFilter.pumping] ?? 0,
          ),
        ],
      ),
    );
  }

  // Widget con: 1 chip filter với label + count badge
  Widget _buildChip(
      BuildContext context, {
        required DeviceFilter filter,
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
            // Count badge
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