import '../utils/display_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/page_header.dart';
import '../data/models.dart';
import '../providers/data_providers.dart';
import '../utils/l10n.dart';

final resolvedAlertIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

class AlertCenterTabScreen extends ConsumerStatefulWidget {
  const AlertCenterTabScreen({super.key});

  @override
  ConsumerState<AlertCenterTabScreen> createState() =>
      _AlertCenterTabScreenState();
}

class _AlertCenterTabScreenState extends ConsumerState<AlertCenterTabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsProvider);
    final resolvedIds = ref.watch(resolvedAlertIdsProvider);
    final unresolved = alerts
        .where((alert) => !resolvedIds.contains(alert.id))
        .toList();
    final resolved = alerts
        .where((alert) => resolvedIds.contains(alert.id))
        .toList();

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
                bottomContent: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.forestGreen,
                  unselectedLabelColor: AppColors.secondaryText,
                  indicatorColor: AppColors.forestGreen,
                  tabs: [
                    Tab(text: context.l10n.all),
                    Tab(text: context.l10n.unresolved),
                    Tab(text: context.l10n.resolved),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AlertList(
                    alerts: alerts,
                    resolvedIds: resolvedIds,
                    onResolve: _resolve,
                    emptyMessage: context.l10n.noAlerts,
                  ),
                  _AlertList(
                    alerts: unresolved,
                    resolvedIds: resolvedIds,
                    onResolve: _resolve,
                    emptyMessage: context.l10n.noUnresolvedAlerts,
                  ),
                  _AlertList(
                    alerts: resolved,
                    resolvedIds: resolvedIds,
                    onResolve: _resolve,
                    emptyMessage: context.l10n.noResolvedAlerts,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resolve(String alertId) {
    final current = ref.read(resolvedAlertIdsProvider);
    ref.read(resolvedAlertIdsProvider.notifier).state = {...current, alertId};
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList({
    required this.alerts,
    required this.resolvedIds,
    required this.onResolve,
    required this.emptyMessage,
  });

  final List<AppAlert> alerts;
  final Set<String> resolvedIds;
  final ValueChanged<String> onResolve;
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
        final isResolved = resolvedIds.contains(alert.id);
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: isResolved
                            ? Chip(
                                label: Text(context.l10n.resolved),
                                avatar: Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: () => onResolve(alert.id),
                                icon: const Icon(Icons.check, size: 18),
                                label: Text(context.l10n.markResolved),
                              ),
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
