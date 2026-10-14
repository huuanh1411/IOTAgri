// lib/core/widgets/floating_pill_nav_bar.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A floating bottom navigation bar with a pill‑shaped background for the selected
/// tab. It mirrors the design described in Phase 3.
class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  static const _icons = [
    Icons.home_outlined,
    Icons.spa_outlined,
    Icons.grid_view_outlined,
  ];

  static const _labels = ['Trang chủ', 'Chọn Giống', 'Điều khiển', 'Khác'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x182F5D3F),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.mintChip : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[index],
                          color: selected
                              ? AppColors.forestGreen
                              : AppColors.primaryText,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[index == 2 ? 3 : index],
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? AppColors.forestGreen
                                : AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
