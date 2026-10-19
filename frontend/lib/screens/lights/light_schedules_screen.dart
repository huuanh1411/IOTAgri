import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/light_schedule.dart';
import '../../services/api_service.dart';

class LightSchedulesScreen extends StatefulWidget {
  const LightSchedulesScreen({super.key, required this.device});

  final Device device;

  @override
  State<LightSchedulesScreen> createState() => _LightSchedulesScreenState();
}

class _LightSchedulesScreenState extends State<LightSchedulesScreen> {
  final _api = ApiService();
  List<LightSchedule> _schedules = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final schedules = await _api.getLightSchedules(widget.device.id);
      if (mounted) setState(() => _schedules = schedules);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final result = await showDialog<_ScheduleDraft>(
      context: context,
      builder: (_) => const _LightScheduleDialog(),
    );
    if (result == null) return;
    try {
      await _api.createLightSchedule(
        widget.device.id,
        result.startTime,
        result.durationSeconds,
        result.days,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể thêm lịch: $error')));
      }
    }
  }

  Future<void> _delete(LightSchedule schedule) async {
    await _api.deleteLightSchedule(widget.device.id, schedule.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Lịch đèn - ${widget.device.name}'),
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _add,
      child: const Icon(Icons.add),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!))
        : _schedules.isEmpty
        ? const Center(child: Text('Chưa có lịch đèn.'))
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedules.length,
              itemBuilder: (_, index) {
                final schedule = _schedules[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(
                      '${schedule.startTime} · ${schedule.durationSeconds ~/ 60} phút',
                    ),
                    subtitle: Text(_days(schedule.weekdayMask)),
                    trailing: IconButton(
                      onPressed: () => _delete(schedule),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
          ),
  );

  String _days(int mask) {
    const labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return [
      for (var day = 0; day < 7; day++)
        if ((mask & (1 << day)) != 0) labels[day],
    ].join(', ');
  }
}

class _ScheduleDraft {
  const _ScheduleDraft(this.startTime, this.durationSeconds, this.days);
  final String startTime;
  final int durationSeconds;
  final List<int> days;
}

class _LightScheduleDialog extends StatefulWidget {
  const _LightScheduleDialog();
  @override
  State<_LightScheduleDialog> createState() => _LightScheduleDialogState();
}

class _LightScheduleDialogState extends State<_LightScheduleDialog> {
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  final _duration = TextEditingController(text: '3600');
  final _days = <int>{1, 2, 3, 4, 5};
  @override
  void dispose() {
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Thêm lịch đèn'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Giờ bật'),
          trailing: Text(_time.format(context)),
          onTap: () async {
            final value = await showTimePicker(
              context: context,
              initialTime: _time,
            );
            if (value != null) setState(() => _time = value);
          },
        ),
        TextField(
          controller: _duration,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Thời gian bật (giây)'),
        ),
        Wrap(
          children: List.generate(
            7,
            (day) => FilterChip(
              label: Text(
                const ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][day],
              ),
              selected: _days.contains(day),
              onSelected: (selected) =>
                  setState(() => selected ? _days.add(day) : _days.remove(day)),
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          final duration = int.tryParse(_duration.text);
          if (duration == null || duration <= 0 || _days.isEmpty) return;
          Navigator.pop(
            context,
            _ScheduleDraft(
              '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}:00',
              duration,
              _days.toList(),
            ),
          );
        },
        child: const Text('Thêm'),
      ),
    ],
  );
}
