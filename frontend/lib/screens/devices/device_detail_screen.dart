import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/device.dart';
import '../../models/sensor_reading.dart';
import '../../models/pump_command.dart';
import '../../models/device_alert.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/custom_buttons.dart';
import '../sensors/sensor_history_screen.dart';
import '../alerts/alerts_screen.dart';
import '../pumps/pump_schedules_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final ApiService _apiService = ApiService();
  SensorReading? _latestReading;
  List<SensorReading> _readings = [];
  List<PumpCommand> _pumpCommands = [];
  List<DeviceAlert> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getDeviceReadings(widget.device.id, limit: 1),
        _apiService.getDeviceReadings(widget.device.id, limit: 20),
        _apiService.getPumpCommands(widget.device.id),
        _apiService.getAlerts(widget.device.id),
      ]);

      setState(() {
        final readings1 = results[0] as List<dynamic>;
        final readings2 = results[1] as List<dynamic>;
        final commandsData = results[2] as Map<String, dynamic>;
        final alertsData = results[3] as Map<String, dynamic>;

        if (readings1.isNotEmpty) {
          _latestReading = SensorReading.fromJson(readings1[0]);
        }
        _readings = readings2.map((data) => SensorReading.fromJson(data)).toList();
        
        final commandsItems = commandsData['items'] as List<dynamic>?;
        _pumpCommands = commandsItems?.map((data) => PumpCommand.fromJson(data)).toList() ?? [];
        
        final alertsItems = alertsData['items'] as List<dynamic>?;
        _alerts = alertsItems?.map((data) => DeviceAlert.fromJson(data)).toList() ?? [];
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
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

  Future<void> _sendPumpCommand(bool isOn, int durationSeconds) async {
    try {
      final commandId = DateTime.now().millisecondsSinceEpoch.toString();
      await _apiService.sendPumpCommand(
        widget.device.id,
        commandId,
        isOn,
        durationSeconds,
      );
      await _loadDeviceData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOn ? 'Đã bật bơm' : 'Đã tắt bơm'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải dữ liệu thiết bị...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadDeviceData,
      );
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _buildDeviceStatus(),
          const TabBar(
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Cảm biến'),
              Tab(text: 'Bơm'),
              Tab(text: 'Cảnh báo'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(),
                _buildSensorsTab(),
                _buildPumpTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.device.isOnline ? Colors.green[50] : Colors.red[50],
      child: Row(
        children: [
          Icon(
            widget.device.isOnline ? Icons.wifi : Icons.wifi_off,
            color: widget.device.isOnline ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.isOnline ? 'Đang hoạt động' : 'Mất kết nối',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.device.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                if (widget.device.lastSeenAt != null)
                  Text(
                    'Lần hoạt động cuối: ${_formatDate(widget.device.lastSeenAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chỉ số cảm biến mới nhất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_latestReading != null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        label: 'Nhiệt độ',
                        value: _latestReading!.temperature?.toStringAsFixed(1) ?? 'N/A',
                        unit: '°C',
                        icon: Icons.thermostat,
                        color: _getTemperatureColor(_latestReading!.temperature),
                        isWarning: (_latestReading!.temperature ?? 0) > 30 || (_latestReading!.temperature ?? 0) < 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Độ ẩm',
                        value: _latestReading!.humidity?.toStringAsFixed(1) ?? 'N/A',
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
                        value: _latestReading!.ph?.toStringAsFixed(1) ?? 'N/A',
                        unit: '',
                        icon: Icons.science,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Mực nước',
                        value: _latestReading!.waterLevel?.toStringAsFixed(1) ?? 'N/A',
                        unit: '%',
                        icon: Icons.opacity,
                        color: _getWaterLevelColor(_latestReading!.waterLevel),
                        isWarning: (_latestReading!.waterLevel ?? 0) < 30,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có dữ liệu cảm biến'),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  text: 'Xem lịch sử',
                  icon: Icons.history,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorHistoryScreen(device: widget.device),
                      ),
                    );
                  },
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Xem cảnh báo',
                  icon: Icons.warning,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlertsScreen(device: widget.device),
                      ),
                    );
                  },
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomElevatedButton(
            text: 'Quản lý lịch trình bơm',
            icon: Icons.schedule,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PumpSchedulesScreen(device: widget.device),
                ),
              );
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsTab() {
    if (_readings.isEmpty) {
      return const EmptyState(
        icon: Icons.sensors,
        title: 'Chưa có dữ liệu cảm biến',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readings.length,
      itemBuilder: (context, index) {
        final reading = _readings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(reading.recordedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactSensor('Nhiệt độ', '${reading.temperature?.toStringAsFixed(1) ?? 'N/A'}°C'),
                    ),
                    Expanded(
                      child: _buildCompactSensor('Độ ẩm', '${reading.humidity?.toStringAsFixed(1) ?? 'N/A'}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactSensor('pH', reading.ph?.toStringAsFixed(1) ?? 'N/A'),
                    ),
                    Expanded(
                      child: _buildCompactSensor('Mực nước', '${reading.waterLevel?.toStringAsFixed(1) ?? 'N/A'}%'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactSensor(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPumpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điều khiển bơm thủ công',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  text: 'Bật bơm (1 phút)',
                  icon: Icons.power_settings_new,
                  backgroundColor: Colors.green,
                  onPressed: () => _sendPumpCommand(true, 60),
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Tắt bơm',
                  icon: Icons.power_off,
                  backgroundColor: Colors.red,
                  onPressed: () => _sendPumpCommand(false, 0),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Lịch sử lệnh bơm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_pumpCommands.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Chưa có lệnh nào',
            )
          else
            ..._pumpCommands.map((command) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  command.isOn ? Icons.toggle_on : Icons.toggle_off,
                  color: command.isOn ? Colors.green : Colors.red,
                ),
                title: Text(command.isOn ? 'BẬT' : 'TẮT'),
                subtitle: Text('${command.durationSeconds} giây'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      command.status,
                      style: TextStyle(
                        color: command.status == 'Acknowledged'
                            ? Colors.green
                            : command.status == 'Failed'
                                ? Colors.red
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(command.issuedAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (_alerts.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle,
        title: 'Không có cảnh báo nào',
        subtitle: 'Tất cả thông số đang ở mức bình thường',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final severity = alert.type == 'HighTemperature' ? AlertSeverity.warning : AlertSeverity.critical;
        return AlertCard(
          title: alert.type == 'HighTemperature' ? 'Nhiệt độ cao' : 'Mực nước thấp',
          message: 'Giá trị: ${alert.measuredValue} - Ngưỡng: ${alert.threshold}',
          timestamp: _formatDate(alert.triggeredAt),
          severity: severity,
        );
      },
    );
  }
}