import 'package:flutter/material.dart';

import '../animation/app_motion.dart';
import '../theme/app_colors.dart';
import '../../utils/l10n.dart';

/// Floating bottom navigation with a single sliding selection indicator.
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
    Icons.notifications_none_outlined,
    Icons.spa_outlined,
    Icons.more_horiz_outlined,
  ];

  static const _labelKeys = ['home', 'alerts', 'choose_plant', 'more'];

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.navigationIndicator);
    final indicatorAlignment = Alignment(
      -1 + (currentIndex * 2 / (_icons.length - 1)),
      0,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: Container(
          padding: const EdgeInsets.all(5),
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
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: indicatorAlignment,
                  duration: duration,
                  curve: AppMotion.easeInOut,
                  child: FractionallySizedBox(
                    widthFactor: 1 / _icons.length,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.mintChip,
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(_icons.length, (index) {
                  final selected = index == currentIndex;
                  final foreground = selected
                      ? AppColors.forestGreen
                      : AppColors.primaryText;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(21),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: duration,
                              switchInCurve: AppMotion.easeOut,
                              switchOutCurve: AppMotion.easeOut,
                              child: Icon(
                                _icons[index],
                                key: ValueKey(selected),
                                color: foreground,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: duration,
                              curve: AppMotion.easeOut,
                              style: TextStyle(fontSize: 10, color: foreground),
                              child: Text(context.tr(_labelKeys[index])),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
