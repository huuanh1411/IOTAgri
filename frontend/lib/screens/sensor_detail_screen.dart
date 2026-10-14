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
                const _DetailRow(
                  label: 'Cập nhật',
                  value: 'Tự động mỗi 3 giây',
                ),
                if (metric == 'water') ...[
                  const SizedBox(height: 24),
                  WaterPumpControlPanel(waterLevel: value),
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
  const WaterPumpControlPanel({required this.waterLevel, super.key});

  final double waterLevel;

  @override
  State<WaterPumpControlPanel> createState() => _WaterPumpControlPanelState();
}

class _WaterPumpControlPanelState extends State<WaterPumpControlPanel> {
  bool _running = false;
  final List<Map<String, dynamic>> _schedules = [];

  void _togglePump(bool enabled) {
    if (enabled && widget.waterLevel < 30) {
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
      builder: (_) => const _LocalScheduleDialog(),
    );
    if (result == null) return;
    setState(() => _schedules.add({...result, 'isEnabled': true}));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Điều khiển bơm thủ công',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_running ? 'Bơm đang bật' : 'Bơm đang tắt'),
              subtitle: const Text('Chỉ mô phỏng trên giao diện frontend'),
              value: _running,
              onChanged: _togglePump,
            ),
            if (widget.waterLevel < 30)
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
                    'Phun ${schedule['durationSeconds']} giây mỗi ${schedule['intervalMinutes']} phút · ${schedule['daysLabel']}\n${schedule['timeZone']} · chỉ hiển thị',
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
  const _LocalScheduleDialog();

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
                decoration: const InputDecoration(
                  labelText: 'Thời gian phun (giây)',
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
