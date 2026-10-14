import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/gauge_ring.dart';
import '../data/models.dart';
import '../models/device.dart';
import '../models/pump_schedule.dart';
import '../providers/data_providers.dart';
import '../services/api_service.dart';
import 'pumps/pump_schedules_screen.dart' show AddScheduleDialog;

class SensorDetailScreen extends ConsumerWidget {
  const SensorDetailScreen({required this.metric, super.key});

  final String metric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = _SensorDetail.forMetric(metric);
    final reading = ref.watch(sensorStreamProvider).valueOrNull;
    final value = detail.valueFrom(reading);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(detail.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GaugeRing(
                  label: detail.label,
                  value: value,
                  unit: detail.unit,
                  color: detail.color,
                  icon: detail.icon,
                ),
                const SizedBox(height: 24),
                Text(
                  detail.status(value),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  detail.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 20),
                _DetailRow(label: 'Khoảng phù hợp', value: detail.idealRange),
                const Divider(height: 28),
                const _DetailRow(
                  label: 'Cập nhật',
                  value: 'Tự động mỗi 3 giây',
                ),
                if (metric == 'water') ...[
                  const SizedBox(height: 24),
                  const WaterPumpControlPanel(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaterPumpControlPanel extends StatefulWidget {
  const WaterPumpControlPanel({super.key});
  @override
  State<WaterPumpControlPanel> createState() => _WaterPumpControlPanelState();
}

class _WaterPumpControlPanelState extends State<WaterPumpControlPanel> {
  final _api = ApiService();
  Device? _device;
  List<dynamic> _schedules = [];
  bool _loading = true;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final devices = await _api.getDevices();
      if (devices.isNotEmpty) {
        final device = Device.fromJson(devices.first as Map<String, dynamic>);
        final schedules = await _api.getPumpSchedules(device.id);
        if (mounted)
          setState(() {
            _device = device;
            _schedules = schedules;
          });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePump(bool enabled) async {
    final device = _device;
    if (device == null || !device.isOnline) return;
    if (enabled) {
      final readings = await _api.getDeviceReadings(device.id, limit: 1);
      final water = readings.isEmpty
          ? null
          : (readings.first as Map<String, dynamic>)['waterLevel'] as num?;
      final settings = await _api.getAlertSettings(device.id);
      final threshold =
          (settings['lowWaterLevelPercent'] as num?)?.toDouble() ?? 30;
      if (water != null && water.toDouble() < threshold) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể bật bơm khi mực nước thấp.'),
            ),
          );
        return;
      }
    }
    setState(() => _running = enabled);
    await _api.sendPumpCommand(
      device.id,
      ApiService.generatePumpCommandId(),
      enabled,
      60,
    );
  }

  Future<void> _addSchedule() async {
    final device = _device;
    if (device == null) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddScheduleDialog(),
    );
    if (result == null) return;
    await _api.createPumpSchedule(
      device.id,
      result['startTime'] as String,
      result['durationSeconds'] as int,
      result['daysOfWeek'] as List<int>,
      endTime: result['endTime'] as String?,
      intervalMinutes: result['intervalMinutes'] as int?,
      activeFromDate: result['activeFromDate'] as DateTime?,
      activeUntilDate: result['activeUntilDate'] as DateTime?,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    if (_device == null)
      return const Text('Chưa có thiết bị bơm để điều khiển.');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Điều khiển bơm & lịch tưới',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bật bơm ngay'),
              subtitle: const Text('Tự dừng sau tối đa 60 giây'),
              value: _running,
              onChanged: _device!.isOnline ? _togglePump : null,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lịch tự động'),
                TextButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm lịch'),
                ),
              ],
            ),
            if (_schedules.isEmpty)
              const Text(
                'Chưa có lịch. Chọn “Thêm lịch” để đặt ngày và khung giờ.',
              )
            else
              ..._schedules.map((raw) {
                final schedule = PumpSchedule.fromJson(
                  raw as Map<String, dynamic>,
                );
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${schedule.startTime} – ${schedule.endTime ?? schedule.startTime}',
                  ),
                  subtitle: Text(
                    'Hiệu lực: ${schedule.activeFromDate ?? 'ngay'} đến ${schedule.activeUntilDate ?? 'vô thời hạn'}',
                  ),
                  value: schedule.isEnabled,
                  onChanged: (enabled) async {
                    await _api.updatePumpSchedule(
                      _device!.id,
                      schedule,
                      isEnabled: enabled,
                    );
                    await _load();
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.secondaryText)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}

class _SensorDetail {
  const _SensorDetail({
    required this.title,
    required this.label,
    required this.unit,
    required this.color,
    required this.icon,
    required this.idealRange,
    required this.description,
    required this.valueFrom,
    required this.status,
  });

  final String title;
  final String label;
  final String unit;
  final Color color;
  final IconData icon;
  final String idealRange;
  final String description;
  final double Function(SensorReading? reading) valueFrom;
  final String Function(double value) status;

  factory _SensorDetail.forMetric(String metric) {
    switch (metric) {
      case 'water':
        return _SensorDetail(
          title: 'Mức nước',
          label: 'MỨC NƯỚC',
          unit: '%',
          color: AppColors.forestGreen,
          icon: Icons.opacity,
          idealRange: '60–80%',
          description:
              'Theo dõi lượng nước trong hệ thống để cây luôn được tưới phù hợp.',
          valueFrom: (reading) => reading?.waterLevel ?? 0,
          status: (value) => value < 30 ? 'Mức nước thấp' : 'Mức nước ổn định',
        );
      case 'nutrient':
        return _SensorDetail(
          title: 'Mức dinh dưỡng',
          label: 'MỨC DINH DƯỠNG',
          unit: '%',
          color: const Color(0xFFF2A93B),
          icon: Icons.science,
          idealRange: '45–70%',
          description:
              'Theo dõi nồng độ dinh dưỡng để hỗ trợ cây phát triển đồng đều.',
          valueFrom: (reading) => reading?.nutrientLevel ?? 0,
          status: (value) =>
              value < 45 ? 'Dinh dưỡng cần bổ sung' : 'Dinh dưỡng ổn định',
        );
      case 'temperature':
        return _SensorDetail(
          title: 'Nhiệt độ',
          label: 'NHIỆT ĐỘ',
          unit: '°C',
          color: const Color(0xFFCDB59A),
          icon: Icons.thermostat,
          idealRange: '20–28°C',
          description: 'Theo dõi nhiệt độ môi trường quanh khu vực trồng cây.',
          valueFrom: (reading) => reading?.temperature ?? 0,
          status: (value) => value < 20 || value > 28
              ? 'Nhiệt độ cần chú ý'
              : 'Nhiệt độ phù hợp',
        );
      default:
        return _SensorDetail(
          title: 'Ánh sáng',
          label: 'ÁNH SÁNG',
          unit: '%',
          color: const Color(0xFFE3A72F),
          icon: Icons.wb_sunny_outlined,
          idealRange: '60–85%',
          description:
              'Theo dõi cường độ ánh sáng để cây nhận đủ năng lượng quang hợp.',
          valueFrom: (reading) => reading?.lightLevel ?? 0,
          status: (value) => value < 60 ? 'Ánh sáng thấp' : 'Ánh sáng phù hợp',
        );
    }
  }
}
