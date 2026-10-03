// ============================================================
// ticket_filter_chips.dart
// Thanh filter chips cho màn hình Support Tickets.
// Cho phép lọc ticket theo: All / Open / InProgress / Closed.
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../theme/cupertino_theme.dart';

enum TicketFilter {
  all,
  open,
  inProgress,
  closed,
}

class TicketFilterChips extends StatelessWidget {
  final TicketFilter selected;
  final ValueChanged<TicketFilter> onChanged;
  final Map<TicketFilter, int> counts;

  const TicketFilterChips({
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
            filter: TicketFilter.all,
            label: 'Tất cả',
            count: counts[TicketFilter.all] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: TicketFilter.open,
            label: 'Mới',
            count: counts[TicketFilter.open] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: TicketFilter.inProgress,
            label: 'Đang xử lý',
            count: counts[TicketFilter.inProgress] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            filter: TicketFilter.closed,
            label: 'Đã đóng',
            count: counts[TicketFilter.closed] ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, {
        required TicketFilter filter,
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