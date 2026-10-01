import 'package:flutter/cupertino.dart';
import '../../models/device_overview.dart';
import '../../services/api_service.dart';

class CupertinoDashboardScreen extends StatefulWidget {
  const CupertinoDashboardScreen({super.key});

  @override
  State<CupertinoDashboardScreen> createState() => _CupertinoDashboardScreenState();
}

class _CupertinoDashboardScreenState extends State<CupertinoDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<DeviceOverview> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getDashboardOverview();
      setState(() {
        _devices = data.map((item) => DeviceOverview.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Trang chủ'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            // TODO: Add device
          },
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 20),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              style: const TextStyle(color: CupertinoColors.systemRed),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _loadDashboardData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.device_phone_portrait,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thiết bị nào',
              style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm thiết bị đầu tiên để bắt đầu',
              style: TextStyle(color: CupertinoColors.systemGrey2),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () {
                // TODO: Add device
              },
              child: const Text('Thêm thiết bị'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Thiết bị của tôi'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final device = _devices[index];
                return _buildDeviceCard(device);
              },
              childCount: _devices.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(DeviceOverview device) {
    final isOnline = device.isOnline;
    final latestReading = device.latestReading;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to device detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isOnline ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                    color: isOnline ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
                    size: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
                          : CupertinoColors.systemRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (latestReading != null) ...[
                _buildSensorValue(
                  'Nhiệt độ',
                  '${latestReading.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                  CupertinoColors.systemOrange,
                ),
                const SizedBox(height: 4),
                _buildSensorValue(
                  'Độ ẩm',
                  '${latestReading.humidity?.toStringAsFixed(1) ?? 'N/A'}%',
                  CupertinoColors.systemBlue,
                ),
              ] else
                const Text(
                  'Chưa có dữ liệu',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorValue(String label, String value, CupertinoDynamicColor color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.resolveFrom(context),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color.resolveFrom(context),
          ),
        ),
      ],
    );
  }
}