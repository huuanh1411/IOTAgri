import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/device_overview.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/loading_indicators.dart';
import '../devices/devices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const DevicesTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF2CBF6B),
        title: const Text(
          'Hệ Thống Giám Sát Nông Nghiệp',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 32),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Thiết bị',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải dữ liệu...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadDashboardData,
      );
    }

    if (_devices.isEmpty) {
      return EmptyState(
        icon: Icons.devices,
        title: 'Chưa có thiết bị nào',
        subtitle: 'Thêm thiết bị đầu tiên để bắt đầu giám sát',
        action: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DevicesScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm thiết bị'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GatewayStatusCard(
              status: 'Đang hoạt động',
              lastUpdate: '10:35',
              runtime: '5h 12m',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng quan thiết bị',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_devices.length} thiết bị',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._devices.map((device) => _buildDeviceCard(device)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(DeviceOverview device) {
    final isOnline = device.isOnline;
    final latestReading = device.latestReading;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DevicesScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    color: isOnline ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOnline ? 'Đang hoạt động' : 'Mất kết nối',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (latestReading != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        label: 'Nhiệt độ',
                        value: latestReading.temperature?.toStringAsFixed(1) ?? 'N/A',
                        unit: '°C',
                        icon: Icons.thermostat,
                        color: _getTemperatureColor(latestReading.temperature),
                        isWarning: (latestReading.temperature ?? 0) > 30 || (latestReading.temperature ?? 0) < 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Độ ẩm',
                        value: latestReading.humidity?.toStringAsFixed(1) ?? 'N/A',
                        unit: '%',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        label: 'pH',
                        value: latestReading.ph?.toStringAsFixed(1) ?? 'N/A',
                        unit: '',
                        icon: Icons.science,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Mực nước',
                        value: latestReading.waterLevel?.toStringAsFixed(1) ?? 'N/A',
                        unit: '%',
                        icon: Icons.opacity,
                        color: _getWaterLevelColor(latestReading.waterLevel),
                        isWarning: (latestReading.waterLevel ?? 0) < 30,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp > 30) return Colors.red;
    if (temp < 15) return Colors.blue;
    return Colors.green;
  }

  Color _getWaterLevelColor(double? level) {
    if (level == null) return Colors.grey;
    if (level < 30) return Colors.red;
    if (level < 50) return Colors.orange;
    return Colors.green;
  }
}

class GatewayStatusCard extends StatelessWidget {
  final String status;
  final String lastUpdate;
  final String runtime;

  const GatewayStatusCard({
    super.key,
    required this.status,
    required this.lastUpdate,
    required this.runtime,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOnline = status.toLowerCase() != 'mất kết nối';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAE0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.signal_wifi_4_bar,
            size: 34,
            color: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ESP32 Gateway',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🟢', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 15,
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last update',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                lastUpdate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Runtime',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                runtime,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevicesScreen();
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tính năng cài đặt sẽ được thêm trong phiên bản tiếp theo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}