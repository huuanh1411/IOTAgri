import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/admin_logout_button.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../theme/cupertino_theme.dart';
import 'admin_quick_stats.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final overview = await _apiService.getAdminOverview();
      if (!mounted) return;
      setState(() {
        _stats = {
          'totalUsers': overview['users'],
          'totalDevices': overview['devices'],
          'onlineDevices': overview['onlineDevices'],
          'totalAlerts': overview['unresolvedAlerts'],
          'unresolvedAlerts': overview['unresolvedAlerts'],
          'openTickets': overview['openTickets'],
        };
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) setState(() {
        _error = '$error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }
    if (_error != null) {
      return Center(child: CupertinoButton(onPressed: _loadData, child: Text(_error!)));
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Tổng quan'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: _loadData,
                child: const Icon(CupertinoIcons.arrow_2_circlepath),
              ),
              const AdminLogoutButton(),
            ],
          ),
        ),
        CupertinoSliverRefreshControl(onRefresh: _loadData),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreeting(context),
              const SizedBox(height: 20),

              if (_stats != null) AdminQuickStats(stats: _stats!),
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
