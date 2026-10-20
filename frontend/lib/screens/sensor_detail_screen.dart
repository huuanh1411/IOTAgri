import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/animation/app_motion.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/gauge_ring.dart';
import '../models/sensor_reading.dart';
import '../models/history_data.dart';
import '../providers/data_providers.dart';
import '../services/api_service.dart';
import '../services/history_repository.dart';
import '../utils/l10n.dart';
import '../utils/display_localizations.dart';

class SensorDetailScreen extends ConsumerWidget {
  const SensorDetailScreen({required this.metric, super.key});

  final String metric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = _SensorDetail.forMetric(metric, context);
    final devices = ref.watch(dashboardDevicesProvider).valueOrNull;
    final reading = devices == null || devices.isEmpty
        ? null
        : devices.first.latestReading;
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
                _DetailRow(
                  label: context.l10n.idealRange,
                  value: detail.idealRange,
                ),
                const Divider(height: 28),
                _SensorHistoryCard(
                  title: detail.historyTitle,
                  metric: metric,
                  color: detail.color,
                ),
                if (metric == 'water') ...[
                  const SizedBox(height: 24),
                  WaterPumpControlPanel(waterLevel: value ?? 0),
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

class _SensorHistoryCard extends StatefulWidget {
  const _SensorHistoryCard({
    required this.title,
    required this.metric,
    required this.color,
  });

  final String title;
  final String metric;
  final Color color;

  @override
  State<_SensorHistoryCard> createState() => _SensorHistoryCardState();
}

class _SensorHistoryCardState extends State<_SensorHistoryCard> {
  final ApiService _apiService = ApiService();
  late final HistoryRepository _repository = ApiHistoryRepository(_apiService);
  HistoryRange _range = HistoryRange.day;
  late Future<_ChartHistory> _history = _loadHistory();

  HistorySensor get _sensor => switch (widget.metric) {
    'water' => HistorySensor.waterLevel,
    'nutrient' => HistorySensor.tds,
    'temperature' => HistorySensor.temperature,
    'light' => HistorySensor.lux,
    'solutionTemperature' => HistorySensor.solutionTemperature,
    'humidity' => HistorySensor.humidity,
    _ => HistorySensor.temperature,
  };

  HistoryWindow _windowFor(HistoryRange range) {
    final now = DateTime.now();
    if (range == HistoryRange.day) {
      return HistoryWindow(
        from: DateTime(now.year, now.month, now.day),
        to: now,
      );
    }
    return HistoryWindow(from: now.subtract(range.duration!), to: now);
  }

  Future<_ChartHistory> _loadHistory() async {
    final devices = await _apiService.getDevices();
    if (devices.isEmpty) {
      return _ChartHistory(window: _windowFor(_range), samples: const []);
    }
    final device = devices.first as Map<String, dynamic>;
    final deviceId = device['id']?.toString();
    if (deviceId == null || deviceId.isEmpty) {
      return _ChartHistory(window: _windowFor(_range), samples: const []);
    }
    final window = _windowFor(_range);
    final samples = await _repository.loadSamples(
      deviceId: deviceId,
      window: window,
      downsample: _range != HistoryRange.day,
    );
    return _ChartHistory(
      window: window,
      samples: samples
          .where((sample) => sample.values[_sensor] != null)
          .toList(growable: false),
    );
  }

  void _selectRange(HistoryRange range) {
    if (range == _range || range.duration == null) return;
    setState(() {
      _range = range;
      _history = _loadHistory();
    });
  }

  void _retry() => setState(() => _history = _loadHistory());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            PopupMenuButton<HistoryRange>(
              tooltip: context.l10n.selectTimeRange,
              initialValue: _range,
              onSelected: _selectRange,
              itemBuilder: (_) => HistoryRange.values
                  .where((range) => range.duration != null)
                  .map(
                    (range) => PopupMenuItem(
                      value: range,
                      child: Text(range.localizedLabel(context.l10n)),
                    ),
                  )
                  .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _range.localizedLabel(context.l10n),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.color.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.expand_more, size: 16, color: widget.color),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.trending_up, size: 17, color: widget.color),
            const SizedBox(width: 6),
            Text(
              context.l10n.trendDescription,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: FutureBuilder<_ChartHistory>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _HistoryMessage(
                  icon: Icons.error_outline,
                  message: context.l10n.sensorHistoryLoadError,
                  actionLabel: context.l10n.retry,
                  onAction: _retry,
                );
              }
              final history = snapshot.data!;
              if (history.samples.isEmpty) {
                return _HistoryMessage(
                  icon: Icons.show_chart,
                  message: context.l10n.noSensorHistory,
                );
              }
              return _SensorLineChart(
                history: history,
                sensor: _sensor,
                color: widget.color,
                range: _range,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChartHistory {
  const _ChartHistory({required this.window, required this.samples});

  final HistoryWindow window;
  final List<HistorySample> samples;
}

class _SensorLineChart extends StatelessWidget {
  const _SensorLineChart({
    required this.history,
    required this.sensor,
    required this.color,
    required this.range,
  });

  final _ChartHistory history;
  final HistorySensor sensor;
  final Color color;
  final HistoryRange range;

  @override
  Widget build(BuildContext context) {
    final values = history.samples
        .map((sample) => sample.values[sensor])
        .whereType<double>()
        .toList(growable: false);
    final yScale = _ChartScale.forValues(
      values,
      fixedPercent: sensor == HistorySensor.waterLevel,
    );
    final latest = history.samples.last.recordedAt;
    final minX = history.window.from.millisecondsSinceEpoch.toDouble();
    final maxX = latest.millisecondsSinceEpoch.toDouble();
    final xInterval = range == HistoryRange.day
        ? const Duration(hours: 6).inMilliseconds.toDouble()
        : math.max(1, (maxX - minX) / 4).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return RepaintBoundary(
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: math.max(minX + 1, maxX).toDouble(),
              minY: yScale.min,
              maxY: yScale.max,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yScale.interval,
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
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: compact ? 48 : 60,
                    interval: yScale.interval,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8,
                      child: Text(
                        _formatAxisValue(value, sensor),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: xInterval,
                    getTitlesWidget: (value, meta) {
                      final timestamp = DateTime.fromMillisecondsSinceEpoch(
                        value.round(),
                      );
                      final isLatest = (value - maxX).abs() < 1000;
                      final overlapsLatest =
                          !isLatest && (maxX - value).abs() < xInterval * 0.35;
                      if (overlapsLatest) return const SizedBox.shrink();
                      final format = range == HistoryRange.day
                          ? DateFormat('HH:mm')
                          : compact
                          ? DateFormat('dd/MM')
                          : DateFormat('dd/MM HH:mm');
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 9,
                        child: Text(
                          format.format(isLatest ? latest : timestamp),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (spot) => LineTooltipItem(
                          '${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(spot.x.round()))}\n'
                          '${_formatTooltipValue(spot.y, sensor)} ${sensor.unit}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (final sample in history.samples)
                      FlSpot(
                        sample.recordedAt.millisecondsSinceEpoch.toDouble(),
                        sample.values[sensor]!,
                      ),
                  ],
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) => spot.x == maxX,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 5,
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
            duration: AppMotion.duration(context, AppMotion.chart),
            curve: AppMotion.easeInOut,
          ),
        );
      },
    );
  }
}

class _ChartScale {
  const _ChartScale(this.min, this.max, this.interval);

  final double min;
  final double max;
  final double interval;

  factory _ChartScale.forValues(
    List<double> values, {
    required bool fixedPercent,
  }) {
    if (fixedPercent) return const _ChartScale(0, 100, 20);
    final dataMin = values.reduce(math.min);
    final dataMax = values.reduce(math.max);
    final span = math.max(dataMax - dataMin, dataMax.abs() * 0.1);
    final rawInterval = math.max(span / 4, 0.01);
    final magnitude = math
        .pow(10, (math.log(rawInterval) / math.ln10).floor())
        .toDouble();
    final normalized = rawInterval / magnitude;
    final nice = normalized <= 1
        ? 1.0
        : normalized <= 2
        ? 2.0
        : normalized <= 5
        ? 5.0
        : 10.0;
    final interval = nice * magnitude;
    final min = (dataMin / interval).floor() * interval;
    var max = (dataMax / interval).ceil() * interval;
    if (max <= min) max = min + interval * 4;
    return _ChartScale(min, max, interval);
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Icon(icon, color: AppColors.secondaryText),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        if (onAction != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

String _formatAxisValue(double value, HistorySensor sensor) {
  final formatted = switch (sensor) {
    HistorySensor.lux when value.abs() >= 1000 =>
      '${(value / 1000).toStringAsFixed(1)}k',
    HistorySensor.tds || HistorySensor.lux => value.toStringAsFixed(0),
    _ => value.toStringAsFixed(value.abs() < 10 ? 1 : 0),
  };
  return sensor.unit.isEmpty ? formatted : '$formatted ${sensor.unit}';
}

String _formatTooltipValue(double value, HistorySensor sensor) =>
    switch (sensor) {
      HistorySensor.tds ||
      HistorySensor.lux ||
      HistorySensor.waterLevel => value.toStringAsFixed(0),
      _ => value.toStringAsFixed(1),
    };

class WaterPumpControlPanel extends StatelessWidget {
  const WaterPumpControlPanel({required this.waterLevel, super.key});

  final double waterLevel;

  @override
  Widget build(BuildContext context) => _ActuatorControlPanel(
    deviceLabel: context.l10n.pumpLabel,
    scheduleActionLabel: context.l10n.sprayAction,
    waterLevel: waterLevel,
  );
}

class LightControlPanel extends StatelessWidget {
  const LightControlPanel({super.key});

  @override
  Widget build(BuildContext context) => _ActuatorControlPanel(
    deviceLabel: context.l10n.lightLabel,
    scheduleActionLabel: context.l10n.turnLightOn,
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
        SnackBar(content: Text(context.l10n.cannotStartPumpLowWater)),
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
              context.l10n.manualControl(widget.deviceLabel.toLowerCase()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            AnimatedScale(
              scale: _running ? 1.015 : 1,
              duration: AppMotion.duration(context, AppMotion.toggle),
              curve: AppMotion.easeOut,
              child: AnimatedContainer(
                duration: AppMotion.duration(context, AppMotion.toggle),
                curve: AppMotion.easeInOut,
                decoration: BoxDecoration(
                  color: _running
                      ? AppColors.mintChip.withValues(alpha: 0.7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _running
                        ? context.l10n.deviceOn(widget.deviceLabel)
                        : context.l10n.deviceOff(widget.deviceLabel),
                  ),
                  subtitle: Text(context.l10n.frontendSimulationOnly),
                  value: _running,
                  onChanged: _toggleActuator,
                ),
              ),
            ),
            if ((widget.waterLevel ?? 100) < 30)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  context.l10n.lowWaterPumpOnlyOff,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.automaticScheduleSimulation),
                TextButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addSchedule),
                ),
              ],
            ),
            if (_schedules.isEmpty)
              Text(context.l10n.noSchedules)
            else
              ..._schedules.map((schedule) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${schedule['startTime']} – ${schedule['endTime']}',
                  ),
                  subtitle: Text(
                    context.l10n.localScheduleSummary(
                      (widget.scheduleActionLabel).toString(),
                      (schedule['durationSeconds']).toString(),
                      (schedule['intervalMinutes']).toString(),
                      (schedule['days'] as List<int>)
                          .map((day) => context.localizedWeekdays[day])
                          .join(', '),
                      (schedule['timeZone']).toString(),
                    ),
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
  List<String> get _dayNames => context.localizedWeekdays;

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

  String _presetLabel(String preset) => switch (preset) {
    'Cây giống' => context.l10n.seedlingsPreset,
    'Rau lá' => context.l10n.leafyPreset,
    'Thảo mộc' => context.l10n.herbsPreset,
    _ => context.l10n.customize,
  };

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.invalidSchedule)));
      return;
    }
    Navigator.pop(context, {
      'durationSeconds': duration,
      'intervalMinutes': interval,
      'startTime': _formatTime(_startTime),
      'endTime': _formatTime(_endTime),
      'days': _selectedDays.toList(),
      'timeZone': _timeZone,
    });
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addScheduleTitle),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.schedulePreset,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Cây giống', 'Rau lá', 'Thảo mộc', 'Tùy chỉnh']
                    .map(
                      (preset) => ChoiceChip(
                        label: Text(_presetLabel(preset)),
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
                  labelText: context.l10n.actionDurationSeconds(
                    (widget.actionLabel.toLowerCase()).toString(),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.scheduleIntervalMinutes,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.scheduleTimeWindow,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: context.l10n.scheduleStart,
                      value: _formatTime(_startTime),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeField(
                      label: context.l10n.scheduleEnd,
                      value: _formatTime(_endTime),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.scheduleRepeatDays,
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
                decoration: InputDecoration(
                  labelText: context.l10n.timezoneLabel,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: _timeZone,
                    child: Text(context.l10n.vietnamTimezone),
                  ),
                ],
                onChanged: null,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.localScheduleNotice,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.save)),
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
  final double? Function(SensorReading? reading) valueFrom;
  final String Function(double? value) status;

  factory _SensorDetail.forMetric(String metric, BuildContext context) {
    switch (metric) {
      case 'water':
        return _SensorDetail(
          title: context.l10n.waterSensorTitle,
          label: context.l10n.waterSensorLabel,
          unit: '%',
          color: AppColors.forestGreen,
          icon: Icons.opacity,
          idealRange: '60–80%',
          description: context.l10n.waterSensorDescription,
          historyTitle: context.l10n.waterSensorHistory,
          valueFrom: (reading) => reading?.waterLevel,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : value < 30
              ? context.l10n.waterSensorLow
              : context.l10n.waterSensorStable,
        );
      case 'nutrient':
        return _SensorDetail(
          title: 'TDS',
          label: 'TDS',
          unit: 'ppm',
          color: const Color(0xFFF2A93B),
          icon: Icons.science,
          idealRange: context.l10n.notConfigured,
          description: context.l10n.nutrientSensorDescription,
          historyTitle: context.l10n.nutrientSensorHistory,
          valueFrom: (reading) => reading?.tds,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : context.l10n.dataReceived,
        );
      case 'temperature':
        return _SensorDetail(
          title: context.l10n.temperatureSensorTitle,
          label: context.l10n.temperatureSensorLabel,
          unit: '°C',
          color: const Color(0xFFCDB59A),
          icon: Icons.thermostat,
          idealRange: '20–28°C',
          description: context.l10n.temperatureSensorDescription,
          historyTitle: context.l10n.temperatureSensorHistory,
          valueFrom: (reading) => reading?.temperature,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : value < 20 || value > 28
              ? context.l10n.temperatureSensorAttention
              : context.l10n.temperatureSensorHealthy,
        );
      case 'solutionTemperature':
        return _SensorDetail(
          title: context.l10n.waterTemperatureSensorTitle,
          label: context.l10n.waterTemperature,
          unit: '°C',
          color: const Color(0xFFC86464),
          icon: Icons.water,
          idealRange: context.l10n.notConfigured,
          description: context.l10n.waterTemperatureSensorDescription,
          historyTitle: context.l10n.waterTemperatureSensorHistory,
          valueFrom: (reading) => reading?.solutionTemperature,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : context.l10n.dataReceived,
        );
      case 'humidity':
        return _SensorDetail(
          title: context.l10n.humiditySensorTitle,
          label: context.l10n.airHumidity,
          unit: '%',
          color: const Color(0xFF4D94C7),
          icon: Icons.water_drop_outlined,
          idealRange: context.l10n.notConfigured,
          description: context.l10n.humiditySensorDescription,
          historyTitle: context.l10n.humiditySensorHistory,
          valueFrom: (reading) => reading?.humidity,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : context.l10n.dataReceived,
        );
      default:
        return _SensorDetail(
          title: context.l10n.lightSensorTitle,
          label: context.l10n.light,
          unit: 'lux',
          color: const Color(0xFFE3A72F),
          icon: Icons.wb_sunny_outlined,
          idealRange: context.l10n.notConfigured,
          description: context.l10n.lightSensorDescription,
          historyTitle: context.l10n.lightSensorHistory,
          valueFrom: (reading) => reading?.lux,
          status: (value) => value == null
              ? context.l10n.noReadingsYet
              : context.l10n.dataReceived,
        );
    }
  }
}
