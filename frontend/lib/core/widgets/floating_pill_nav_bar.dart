// lib/core/widgets/floating_pill_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/ui_consts.dart';
import '../../providers/navigation_provider.dart';

/// Floating navigation bar with four items. The selected item gets a mint‑colored pill
/// background that animates (250 ms). Items are displayed as icon above a label.
class FloatingPillNavBar extends ConsumerWidget {
  const FloatingPillNavBar({super.key});

  static const _items = [
    _NavItem(icon: Icons.home, label: 'Trang chủ'),
    _NavItem(icon: Icons.local_florist, label: 'Chọn Giống'),
    _NavItem(icon: Icons.settings_remote, label: 'Điều khiển'),
    _NavItem(icon: Icons.more_horiz, label: 'Khác'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(UIConsts.navBarRadius),
          color: Colors.white,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(navIndexProvider.notifier).state = index;
                      switch (index) {
                        case 0:
                          context.go('/home');
                          break;
                        case 1:
                          context.go('/plants');
                          break;
                        case 2:
                          context.go('/control');
                          break;
                        case 3:
                          context.go('/more');
                          break;
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.mintChip : Colors.transparent,
                            borderRadius: BorderRadius.circular(UIConsts.chipRadius),
                          ),
                          child: Icon(item.icon,
                              size: 24,
                              color: isSelected ? AppColors.forest : AppColors.secondaryText),
                        ),
                        const SizedBox(height: 4),
                        Text(item.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isSelected ? AppColors.forest : AppColors.secondaryText,
                                  fontWeight: FontWeight.w600,
                                )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
