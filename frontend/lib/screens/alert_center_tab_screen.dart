import '../utils/display_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/page_header.dart';
import '../data/models.dart';
import '../providers/data_providers.dart';
import '../utils/l10n.dart';

class AlertCenterTabScreen extends ConsumerWidget {
  const AlertCenterTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ hiển thị cảnh báo; bỏ các tab và thao tác đánh dấu đã xử lý.
    final alerts = ref.watch(alertsProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: PageHeader(
                title: context.l10n.alerts,
                subtitle: context.l10n.alertsSubtitle,
              ),
            ),
            Expanded(
              child: _AlertList(
                alerts: alerts,
                emptyMessage: context.l10n.noAlerts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList({
    required this.alerts,
    required this.emptyMessage,
  });

  final List<AppAlert> alerts;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      itemCount: alerts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final isWarning = alert.type == 'warning';
        final color = isWarning ? AppColors.alertRed : AppColors.forestGreen;
        return Card(
          elevation: 4,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: .12),
                  child: Icon(
                    isWarning
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.localizedTitle(context.l10n),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.localizedMessage(context.l10n),
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
