// ============================================================
// cupertino_monitoring_screen.dart
// Màn hình giám sát hệ thống (System Monitoring).
// Chức năng:
//   - Server status: CPU, RAM, Uptime
//   - MQTT Broker: Connections, Messages/sec, Topics
//   - Database: Size, Queries/sec, Response time
//   - Device Network: Online/Offline summary
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../services/mock_admin_service.dart';
import '../../theme/cupertino_theme.dart';

class CupertinoMonitoringScreen extends StatefulWidget {
  const CupertinoMonitoringScreen({super.key});

  @override
  State<CupertinoMonitoringScreen> createState() =>
      _CupertinoMonitoringScreenState();
}

class _CupertinoMonitoringScreenState
    extends State<CupertinoMonitoringScreen> {
  final _mockService = MockAdminService();

  Map<String, dynamic>? _health;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _health = _mockService.getMockSystemHealth();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Giám sát'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: _loadData,
            child: const Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ),
        CupertinoSliverRefreshControl(onRefresh: _loadData),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CupertinoActivityIndicator(radius: 14)),
                )
              else if (_health != null) ...[
                _buildServerCard(context),
                const SizedBox(height: 16),
                _buildMqttCard(context),
                const SizedBox(height: 16),
                _buildDatabaseCard(context),
                const SizedBox(height: 16),
                _buildDeviceNetworkCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  // ==================== SERVER CARD ====================
  Widget _buildServerCard(BuildContext context) {
    final server = _health!['server'] as Map<String, dynamic>;
    final cpu = (server['cpu'] as num?)?.toDouble() ?? 0;
    final ram = (server['ram'] as num?)?.toDouble() ?? 0;
    final uptime = server['uptimeDays'] as int? ?? 0;

    return _SystemCard(
      icon: CupertinoIcons.desktopcomputer,
      iconColor: CupertinoColors.systemBlue,
      title: 'Server',
      status: server['status'] as String? ?? 'unknown',
      children: [
        _MetricRow(label: 'CPU', value: '${cpu.toStringAsFixed(1)}%'),
        _MetricBar(value: cpu / 100, color: CupertinoColors.systemBlue),
        const SizedBox(height: 12),
        _MetricRow(label: 'RAM', value: '${ram.toStringAsFixed(1)}%'),
        _MetricBar(value: ram / 100, color: CupertinoColors.systemPurple),
        const SizedBox(height: 12),
        _MetricRow(label: 'Uptime', value: '$uptime ngày'),
      ],
    );
  }

  // ==================== MQTT CARD ====================
  Widget _buildMqttCard(BuildContext context) {
    final mqtt = _health!['mqtt'] as Map<String, dynamic>;
    final connections = mqtt['connections'] ?? 0;
    final messages = mqtt['messagesPerSec'] ?? 0;
    final topics = mqtt['topics'] ?? 0;

    return _SystemCard(
      icon: CupertinoIcons.antenna_radiowaves_left_right,
      iconColor: CupertinoColors.systemTeal,
      title: 'MQTT Broker',
      status: mqtt['status'] as String? ?? 'unknown',
      children: [
        _MetricRow(label: 'Connections', value: '$connections'),
        const SizedBox(height: 8),
        _MetricRow(label: 'Messages/sec', value: '$messages'),
        const SizedBox(height: 8),
        _MetricRow(label: 'Topics', value: '$topics'),
      ],
    );
  }

  // ==================== DATABASE CARD ====================
  Widget _buildDatabaseCard(BuildContext context) {
    final database = _health!['database'] as Map<String, dynamic>;
    final size = (database['sizeGb'] as num?)?.toDouble() ?? 0;
    final queries = database['queriesPerSec'] ?? 0;
    final response = database['responseTimeMs'] ?? 0;

    return _SystemCard(
      icon: CupertinoIcons.archivebox_fill,
      iconColor: CupertinoColors.systemOrange,
      title: 'Database',
      status: database['status'] as String? ?? 'unknown',
      children: [
        _MetricRow(label: 'Size', value: '${size.toStringAsFixed(2)} GB'),
        const SizedBox(height: 8),
        _MetricRow(label: 'Queries/sec', value: '$queries'),
        const SizedBox(height: 8),
        _MetricRow(label: 'Response', value: '${response}ms'),
      ],
    );
  }

  // ==================== DEVICE NETWORK CARD ====================
  Widget _buildDeviceNetworkCard(BuildContext context) {
    final online = _health!['onlineDevices'] as int? ?? 0;
    final total = _health!['totalDevices'] as int? ?? 1;
    final offline = total - online;
    final onlinePercent = total > 0 ? online / total : 0.0;

    return _SystemCard(
      icon: CupertinoIcons.device_phone_portrait,
      iconColor: AerogreenCupertinoTheme.aerogreenPrimary,
      title: 'Device Network',
      status: 'online',
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$online',
                    style: TextStyle(
                      color: AerogreenCupertinoTheme.aerogreenPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      color:
                      CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$offline',
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color:
                      CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 8,
                color: CupertinoColors.systemRed.withValues(alpha: 0.3),
              ),
              FractionallySizedBox(
                widthFactor: onlinePercent,
                child: Container(
                  height: 8,
                  color: AerogreenCupertinoTheme.aerogreenPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(onlinePercent * 100).toStringAsFixed(0)}% thiết bị đang hoạt động',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widget con: Card hệ thống (dùng chung cho 4 card)
// ============================================================
class _SystemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final List<Widget> children;

  const _SystemCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = status == 'online';
    final statusColor = isOnline
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemRed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Status dot + text
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          ...children,
        ],
      ),
    );
  }
}

// ============================================================
// Widget con: Row metric (label + value)
// ============================================================
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widget con: Progress bar (cho CPU, RAM)
// ============================================================
class _MetricBar extends StatelessWidget {
  final double value;
  final Color color;

  const _MetricBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Container(
              height: 6,
              color: color.withValues(alpha: 0.15),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(height: 6, color: color),
            ),
          ],
        ),
      ),
    );
  }
}