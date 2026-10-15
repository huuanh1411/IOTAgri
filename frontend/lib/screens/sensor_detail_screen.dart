import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/gauge_ring.dart';
import '../data/models.dart';
import '../providers/data_providers.dart';

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
      body: SingleChildScrollView(
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
                _SensorHistoryCard(
                  title: detail.historyTitle,
                  currentValue: value,
                  color: detail.color,
                  minY: detail.historyMin,
                  maxY: detail.historyMax,
                  variation: detail.historyVariation,
                ),
                if (metric == 'water') ...[
                  const SizedBox(height: 24),
                  WaterPumpControlPanel(waterLevel: value),
                ],
                if (metric == 'light') ...[
                  const SizedBox(height: 24),
                  const LightControlPanel(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SensorHistoryCard extends StatelessWidget {
  const _SensorHistoryCard({
    required this.title,
    required this.currentValue,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.variation,
  });

  final String title;
  final double currentValue;
  final Color color;
  final double minY;
  final double maxY;
  final double variation;

  @override
  Widget build(BuildContext context) {
    final level = currentValue.clamp(minY, maxY).toDouble();
    final values = <double>[
      level + variation * 0.5,
      level - variation,
      level - variation * 0.4,
      level - variation * 1.5,
      level + variation * 0.25,
      level - variation * 0.75,
      level - variation * 1.75,
      level + variation * 0.75,
      level - variation,
      level,
    ].map((value) => value.clamp(minY, maxY).toDouble()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '24 giờ',
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.trending_up, size: 17, color: color),
            SizedBox(width: 6),
            Text(
              'Theo dõi xu hướng thay đổi',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 9,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFD9E7DD),
                  strokeWidth: 1,
                  dashArray: [7, 7],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 4.5,
                    getTitlesWidget: (value, _) {
                      final label = switch (value.round()) {
                        0 => '00:00',
                        5 => '12:00',
                        9 => 'Hiện tại',
                        _ => '',
                      };
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var index = 0; index < values.length; index++)
                      FlSpot(index.toDouble(), values[index]),
                  ],
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) => spot.x == 9,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 6,
                      color: color,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WaterPumpControlPanel extends StatelessWidget {
  const WaterPumpControlPanel({required this.waterLevel, super.key});

  final double waterLevel;

  @override
  Widget build(BuildContext context) => _ActuatorControlPanel(
    deviceLabel: 'Bơm',
    scheduleActionLabel: 'Phun',
    waterLevel: waterLevel,
  );
}

class LightControlPanel extends StatelessWidget {
  const LightControlPanel({super.key});

  @override
  Widget build(BuildContext context) => const _ActuatorControlPanel(
    deviceLabel: 'Đèn',
    scheduleActionLabel: 'Bật đèn',
  );
}

class _ActuatorControlPanel extends StatefulWidget {
  const _ActuatorControlPanel({
    required this.deviceLabel,
    required this.scheduleActionLabel,
    this.waterLevel,
  });

  final String deviceLabel;
  final String scheduleActionLabel;
  final double? waterLevel;

  @override
  State<_ActuatorControlPanel> createState() => _ActuatorControlPanelState();
}

class _ActuatorControlPanelState extends State<_ActuatorControlPanel> {
  bool _running = false;
  final List<Map<String, dynamic>> _schedules = [];

  void _toggleActuator(bool enabled) {
    if (enabled && (widget.waterLevel ?? 100) < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể bật bơm khi mực nước thấp.')),
      );
      return;
    }
    setState(() => _running = enabled);
  }

  Future<void> _addSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          _LocalScheduleDialog(actionLabel: widget.scheduleActionLabel),
    );
    if (result == null) return;
    setState(() => _schedules.add({...result, 'isEnabled': true}));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điều khiển ${widget.deviceLabel.toLowerCase()} thủ công',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _running
                    ? '${widget.deviceLabel} đang bật'
                    : '${widget.deviceLabel} đang tắt',
              ),
              subtitle: const Text('Chỉ mô phỏng trên giao diện frontend'),
              value: _running,
              onChanged: _toggleActuator,
            ),
            if ((widget.waterLevel ?? 100) < 30)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Mức nước dưới 30%: chỉ có thể tắt bơm.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lịch tự động (mô phỏng)'),
                TextButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm lịch'),
                ),
              ],
            ),
            if (_schedules.isEmpty)
              const Text(
                'Chưa có lịch. Chọn “Thêm lịch” để xem lịch trên giao diện.',
              )
            else
              ..._schedules.map((schedule) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${schedule['startTime']} – ${schedule['endTime']}',
                  ),
                  subtitle: Text(
                    '${widget.scheduleActionLabel} ${schedule['durationSeconds']} giây mỗi ${schedule['intervalMinutes']} phút · ${schedule['daysLabel']}\n${schedule['timeZone']} · chỉ hiển thị',
                  ),
                  value: schedule['isEnabled'] as bool,
                  onChanged: (enabled) =>
                      setState(() => schedule['isEnabled'] = enabled),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _LocalScheduleDialog extends StatefulWidget {
  const _LocalScheduleDialog({required this.actionLabel});

  final String actionLabel;

  @override
  State<_LocalScheduleDialog> createState() => _LocalScheduleDialogState();
}

class _LocalScheduleDialogState extends State<_LocalScheduleDialog> {
  static const _timeZone = 'Asia/Ho_Chi_Minh · GMT+07:00';
  static const _dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  final _durationController = TextEditingController(text: '30');
  final _intervalController = TextEditingController(text: '30');
  final _selectedDays = <int>{1, 2, 3, 4, 5, 6};
  var _startTime = const TimeOfDay(hour: 7, minute: 0);
  var _endTime = const TimeOfDay(hour: 19, minute: 0);
  var _preset = 'Tùy chỉnh';

  @override
  void dispose() {
    _durationController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    const settings = {
      'Cây giống': (duration: '30', interval: '30'),
      'Rau lá': (duration: '45', interval: '60'),
      'Thảo mộc': (duration: '20', interval: '45'),
    };
    setState(() {
      _preset = preset;
      final values = settings[preset];
      if (values != null) {
        _durationController.text = values.duration;
        _intervalController.text = values.interval;
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    final duration = int.tryParse(_durationController.text);
    final interval = int.tryParse(_intervalController.text);
    if (duration == null ||
        duration <= 0 ||
        interval == null ||
        interval <= 0 ||
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhập thời gian hợp lệ và chọn ít nhất một ngày.'),
        ),
      );
      return;
    }
    Navigator.pop(context, {
      'durationSeconds': duration,
      'intervalMinutes': interval,
      'startTime': _formatTime(_startTime),
      'endTime': _formatTime(_endTime),
      'daysLabel': _selectedDays.map((day) => _dayNames[day]).join(', '),
      'timeZone': _timeZone,
    });
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm lịch trình'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mẫu cài đặt',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Cây giống', 'Rau lá', 'Thảo mộc', 'Tùy chỉnh']
                    .map(
                      (preset) => ChoiceChip(
                        label: Text(preset),
                        selected: _preset == preset,
                        onSelected: (_) => _applyPreset(preset),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Thời gian ${widget.actionLabel.toLowerCase()} (giây)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Khoảng cách (phút)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Khung giờ hoạt động',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'Bắt đầu',
                      value: _formatTime(_startTime),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeField(
                      label: 'Kết thúc',
                      value: _formatTime(_endTime),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ngày lặp lại',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(
                  7,
                  (day) => FilterChip(
                    label: Text(_dayNames[day]),
                    selected: _selectedDays.contains(day),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _selectedDays.add(day)
                          : _selectedDays.remove(day),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _timeZone,
                decoration: const InputDecoration(
                  labelText: 'Múi giờ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: _timeZone,
                    child: Text('Việt Nam · GMT+07:00'),
                  ),
                ],
                onChanged: null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Lịch này chỉ hiển thị trên frontend, chưa gửi tới thiết bị hoặc backend.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
  );
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
    required this.historyTitle,
    required this.historyMin,
    required this.historyMax,
    required this.historyVariation,
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
  final String historyTitle;
  final double historyMin;
  final double historyMax;
  final double historyVariation;
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
          historyTitle: 'Lịch sử mức nước',
          historyMin: 0,
          historyMax: 100,
          historyVariation: 4,
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
          historyTitle: 'Lịch sử mức dinh dưỡng',
          historyMin: 0,
          historyMax: 100,
          historyVariation: 4,
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
          historyTitle: 'Lịch sử nhiệt độ',
          historyMin: 10,
          historyMax: 40,
          historyVariation: 1.2,
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
          historyTitle: 'Lịch sử ánh sáng',
          historyMin: 0,
          historyMax: 100,
          historyVariation: 5,
          valueFrom: (reading) => reading?.lightLevel ?? 0,
          status: (value) => value < 60 ? 'Ánh sáng thấp' : 'Ánh sáng phù hợp',
        );
    }
  }
}
