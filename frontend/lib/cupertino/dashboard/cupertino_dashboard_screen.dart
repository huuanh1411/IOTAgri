import 'package:flutter/cupertino.dart';

import '../../models/device_overview.dart';
import '../../services/api_service.dart';
import '../theme/cupertino_theme.dart';

class CupertinoDashboardScreen extends StatefulWidget {
  const CupertinoDashboardScreen({super.key});

  @override
  State<CupertinoDashboardScreen> createState() => _CupertinoDashboardScreenState();
}

class _CupertinoDashboardScreenState extends State<CupertinoDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<DeviceOverview> _devices = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final data = await _apiService.getDashboardOverview();
      if (!mounted) return;
      setState(() {
        _devices = data
          .map((item) => DeviceOverview.fromJson(item as Map<String, dynamic>))
          .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop) _buildSidebar(context),
                Expanded(child: _buildContent(context, isDesktop)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    final content = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Aerogreen'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: _loadDashboardData,
            child: const Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 20, 8, isDesktop ? 32 : 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreeting(context),
              const SizedBox(height: 24),
              if (_isLoading)
                const _LoadingPanel()
              else if (_errorMessage != null)
                _ErrorPanel(message: _errorMessage!, onRetry: _loadDashboardData)
              else ...[
                _buildOverviewCard(context),
                const SizedBox(height: 28),
                _sectionHeader(context, 'Không gian của bạn', '${_devices.length} thiết bị'),
                const SizedBox(height: 12),
                _buildDeviceGrid(context, isDesktop),
                const SizedBox(height: 28),
                _sectionHeader(context, 'Tác vụ nhanh', null),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 28),
                _buildInsightCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
    if (isDesktop) return content;
    return Column(children: [Expanded(child: content), _buildBottomBar(context)]);
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Chào buổi sáng' : hour < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 15)),
              const SizedBox(height: 3),
              Text('Nông trại đang trong tầm tay.', style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 19, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AerogreenCupertinoTheme.aerogreenPrimary.withValues(alpha: 0.14), shape: BoxShape.circle),
          child: const Icon(CupertinoIcons.person_fill, color: AerogreenCupertinoTheme.aerogreenPrimary),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final onlineCount = _devices.where((device) => device.isOnline).length;
    final alertCount = _devices.fold<int>(0, (count, device) => count + device.alerts.length);
    final allOnline = _devices.isNotEmpty && onlineCount == _devices.length;
    return _Surface(
      color: AerogreenCupertinoTheme.aerogreenPrimary,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(CupertinoIcons.leaf_arrow_circlepath, color: CupertinoColors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Tổng quan hôm nay', style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            _StatusPill(label: allOnline ? 'Ổn định' : 'Cần chú ý', isPositive: allOnline, light: true),
          ]),
          const SizedBox(height: 22),
          Text(allOnline ? 'Mọi hệ thống đang hoạt động tốt.' : 'Một vài thiết bị cần được kiểm tra.', style: const TextStyle(color: CupertinoColors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.15)),
          const SizedBox(height: 22),
          Row(children: [
            _SummaryMetric(value: '$onlineCount/${_devices.length}', label: 'Thiết bị online'),
            _SummaryMetric(value: '$alertCount', label: 'Cảnh báo'),
            const _SummaryMetric(value: '24°', label: 'Nhiệt độ trung bình'),
          ]),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(BuildContext context, bool isDesktop) {
    if (_devices.isEmpty) {
      return _Surface(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(CupertinoIcons.device_phone_portrait, size: 32, color: CupertinoColors.systemGrey),
          const SizedBox(height: 12),
          Text('Chưa có thiết bị', style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text('Thêm controller đầu tiên để bắt đầu theo dõi.', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
        ]),
      );
    }
    final columns = isDesktop ? 3 : MediaQuery.sizeOf(context).width >= 600 ? 2 : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _devices.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: columns == 1 ? 1.35 : 1.05,
      ),
      itemBuilder: (context, index) => _DeviceCard(device: _devices[index]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      (CupertinoIcons.power, 'Điều khiển bơm', CupertinoColors.systemOrange),
      (CupertinoIcons.calendar, 'Lịch tự động', CupertinoColors.systemBlue),
      (CupertinoIcons.add_circled, 'Thêm thiết bị', AerogreenCupertinoTheme.aerogreenPrimary),
    ];
    return Row(
      children: actions.map((action) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _Surface(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(children: [
              Icon(action.$1, color: action.$3, size: 24),
              const SizedBox(height: 9),
              Text(action.$2, textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: CupertinoColors.systemYellow.withValues(alpha: 0.18), shape: BoxShape.circle), child: const Icon(CupertinoIcons.lightbulb_fill, color: CupertinoColors.systemYellow)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gợi ý từ Aerogreen', style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Theo dõi độ ẩm đất trước khi bật tưới để tiết kiệm nước.', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13, height: 1.35)),
        ])),
        const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey2, size: 18),
      ]),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String? trailing) => Row(children: [Expanded(child: Text(title, style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 21, fontWeight: FontWeight.w700))), if (trailing != null) Text(trailing, style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13))]);

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 28, 16, 20),
      decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground.resolveFrom(context), border: Border(right: BorderSide(color: CupertinoColors.separator.resolveFrom(context)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(CupertinoIcons.leaf_arrow_circlepath, color: AerogreenCupertinoTheme.aerogreenPrimary), const SizedBox(width: 10), Text('Aerogreen', style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 20, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 36),
        _SidebarItem(icon: CupertinoIcons.house_fill, label: 'Tổng quan', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
        _SidebarItem(icon: CupertinoIcons.square_grid_2x2, label: 'Thiết bị', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
        _SidebarItem(icon: CupertinoIcons.bell_fill, label: 'Cảnh báo', selected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
        const Spacer(),
        Text('TRẠNG THÁI HỆ THỐNG', style: TextStyle(color: CupertinoColors.tertiaryLabel.resolveFrom(context), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 10),
        Row(children: [const Icon(CupertinoIcons.checkmark_circle_fill, color: AerogreenCupertinoTheme.aerogreenPrimary, size: 17), const SizedBox(width: 8), Text('Dịch vụ đang hoạt động', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 12))]),
      ]),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: CupertinoColors.systemBackground.resolveFrom(context).withValues(alpha: 0.94), border: Border(top: BorderSide(color: CupertinoColors.separator.resolveFrom(context)))),
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _BottomItem(icon: CupertinoIcons.house_fill, label: 'Trang chủ', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
        _BottomItem(icon: CupertinoIcons.square_grid_2x2, label: 'Thiết bị', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
        _BottomItem(icon: CupertinoIcons.bell, label: 'Cảnh báo', selected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
      ]),
    );
  }
}

class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const _Surface({required this.child, this.padding = EdgeInsets.zero, this.color});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: color ?? CupertinoColors.secondarySystemBackground.resolveFrom(context), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: CupertinoColors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 7))]),
    padding: padding,
    child: child,
  );
}

class _DeviceCard extends StatelessWidget {
  final DeviceOverview device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final reading = device.latestReading;
    final statusColor = device.isOnline ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.systemRed;
    return _Surface(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(device.isOnline ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash, color: statusColor, size: 19), const Spacer(), _StatusPill(label: device.isOnline ? 'Online' : 'Offline', isPositive: device.isOnline)]),
        const SizedBox(height: 15),
        Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text('ESP32 Controller', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 12)),
        const Spacer(),
        Row(children: [_Reading(icon: CupertinoIcons.thermometer, value: reading?.temperature == null ? '--' : '${reading!.temperature!.toStringAsFixed(1)}°', color: CupertinoColors.systemOrange), const SizedBox(width: 18), _Reading(icon: CupertinoIcons.drop_fill, value: reading?.humidity == null ? '--' : '${reading!.humidity!.toStringAsFixed(0)}%', color: CupertinoColors.systemBlue)]),
      ]),
    );
  }
}

class _Reading extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _Reading({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 5), Text(value, style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 15, fontWeight: FontWeight.w700))]);
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isPositive;
  final bool light;

  const _StatusPill({required this.label, required this.isPositive, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.systemRed;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: light ? CupertinoColors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: light ? CupertinoColors.white : color, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: CupertinoColors.white, fontSize: 19, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11))]));
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), alignment: Alignment.centerLeft, onPressed: onTap, child: Row(children: [Icon(icon, size: 18, color: selected ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.secondaryLabel.resolveFrom(context)), const SizedBox(width: 12), Text(label, style: TextStyle(color: selected ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.label.resolveFrom(context), fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.w400))]));
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), minSize: 44, onPressed: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 21, color: selected ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.secondaryLabel.resolveFrom(context)), const SizedBox(height: 3), Text(label, style: TextStyle(fontSize: 10, color: selected ? AerogreenCupertinoTheme.aerogreenPrimary : CupertinoColors.secondaryLabel.resolveFrom(context)))]));
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 260, child: Center(child: CupertinoActivityIndicator(radius: 14)));
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => _Surface(padding: const EdgeInsets.all(24), child: Column(children: [const Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemOrange, size: 30), const SizedBox(height: 12), Text('Không thể tải dữ liệu', style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text(message, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 12)), const SizedBox(height: 16), CupertinoButton.filled(padding: const EdgeInsets.symmetric(horizontal: 22), onPressed: onRetry, child: const Text('Thử lại'))]));
}
