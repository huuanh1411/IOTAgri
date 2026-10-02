import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/mock_admin_service.dart';
import '../../theme/cupertino_theme.dart';
import 'admin_system_health_card.dart';
import 'admin_quick_stats.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final _mockService = MockAdminService();
  bool _isLoading = true;

  Map<String, dynamic>? _systemHealth;
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // Giả lập loading
    if (!mounted) return;
    setState(() {
      _systemHealth = _mockService.getMockSystemHealth();
      _alerts = _mockService
          .getMockAlerts()
          .where((a) => a['severity'] == 'critical' && a['isResolved'] != true)
          .take(5)
          .toList();
      _tickets = _mockService
          .getMockTickets()
          .where((t) => t['status'] != 'closed')
          .take(3)
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Tổng quan'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: _loadData,
            child: const Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ),
        CupertinoSliverRefreshControl(onRefresh: _loadData),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreeting(context),
              const SizedBox(height: 20),

              // 1. System Health Card
              if (_systemHealth != null)
                AdminSystemHealthCard(systemHealth: _systemHealth!),
              const SizedBox(height: 20),

              // 2. Quick Stats
              if (_systemHealth != null)
                AdminQuickStats(stats: _systemHealth!),
              const SizedBox(height: 26),

              // 3. Critical Alerts
              if (_alerts.isNotEmpty) ...[
                _sectionHeader(context, 'Cần xử lý ngay', '${_alerts.length} vấn đề'),
                const SizedBox(height: 12),
                ..._alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AlertCard(alert: alert),
                )),
                const SizedBox(height: 26),
              ],

              // 4. Open Tickets
              if (_tickets.isNotEmpty) ...[
                _sectionHeader(context, 'Tickets đang mở', '${_tickets.length} ticket'),
                const SizedBox(height: 12),
                ..._tickets.map((ticket) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TicketCard(ticket: ticket),
                )),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
        ? 'Chào buổi chiều'
        : 'Chào buổi tối';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                user?.fullName ?? 'Admin',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AerogreenCupertinoTheme.aerogreenPrimary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.shield_lefthalf_fill,
            color: CupertinoColors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ==================== ALERT CARD ====================
class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final severity = alert['severity'] as String? ?? 'info';
    final color = _severityColor(severity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _severityIcon(severity),
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['deviceName'] ?? 'Thiết bị',
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert['message'] ?? '',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: CupertinoColors.tertiaryLabel,
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return CupertinoColors.systemRed;
      case 'warning':
        return CupertinoColors.systemOrange;
      default:
        return CupertinoColors.systemBlue;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return CupertinoIcons.exclamationmark_octagon_fill;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }
}

// ==================== TICKET CARD ====================
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] as String? ?? 'open';
    final color = status == 'open'
        ? CupertinoColors.systemRed
        : CupertinoColors.systemOrange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['subject'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ticket['userName']} • ${status == 'open' ? 'Mới' : 'Đang xử lý'}',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: CupertinoColors.tertiaryLabel,
          ),
        ],
      ),
    );
  }
}