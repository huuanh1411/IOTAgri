import '../utils/display_localizations.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/page_header.dart';
import '../models/device_alert.dart';
import '../services/api_service.dart';
import '../utils/l10n.dart';

class AlertCenterTabScreen extends StatefulWidget {
  const AlertCenterTabScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<AlertCenterTabScreen> createState() => _AlertCenterTabScreenState();
}

class _AlertCenterTabScreenState extends State<AlertCenterTabScreen> {
  late final ApiService _apiService;
  late Future<List<DeviceAlert>> _alerts;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _alerts = _loadOpenAlerts();
  }

  Future<List<DeviceAlert>> _loadOpenAlerts() async {
    final devices = await _apiService.getDevices();
    final responses = await Future.wait(
      devices.map((device) {
        final deviceId =
            (device as Map<String, dynamic>)['id']?.toString() ?? '';
        if (deviceId.isEmpty) return Future.value(<DeviceAlert>[]);
        return _apiService
            .getAlerts(deviceId, status: 'active')
            .then(
              (data) => (data['items'] as List<dynamic>? ?? const [])
                  .map(
                    (item) => DeviceAlert.fromJson(
                      item as Map<String, dynamic>,
                      deviceId: deviceId,
                    ),
                  )
                  .toList(),
            );
      }),
    );
    return responses.expand((alerts) => alerts).toList()
      ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị cảnh báo; bỏ các tab và thao tác đánh dấu đã xử lý.
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
              child: FutureBuilder<List<DeviceAlert>>(
                future: _alerts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        localizedApiError(snapshot.error!, context.l10n),
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    );
                  }
                  return _AlertList(
                    alerts: snapshot.data ?? const [],
                    emptyMessage: context.l10n.noAlerts,
                  );
                },
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

  final List<DeviceAlert> alerts;
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
        final isWarning = alert.severity != AlertLevel.info;
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
