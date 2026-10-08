import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/device.dart';
import '../../models/device_alert.dart';
import '../../models/pump_command.dart';
import '../../models/pump_schedule.dart';
import '../../models/sensor_reading.dart';
import '../../screens/sensors/sensor_history_screen.dart';
import '../../screens/alerts/alerts_screen.dart';
import '../../services/api_service.dart';
import '../theme/cupertino_theme.dart';
import 'pump_schedules_screen.dart';

enum PumpMode { auto, manual }

class CupertinoDeviceDetailScreen extends StatefulWidget {
  final Device device;
  final ApiService? apiService;
  final String? initialSensor;

  const CupertinoDeviceDetailScreen({
    super.key,
    required this.device,
    this.apiService,
    this.initialSensor,
  });

  @override
  State<CupertinoDeviceDetailScreen> createState() =>
      _CupertinoDeviceDetailScreenState();
}

class _CupertinoDeviceDetailScreenState
    extends State<CupertinoDeviceDetailScreen> {
  late final ApiService _apiService;
  late Device _device;
  List<SensorReading> _readings = const [];
  List<PumpCommand> _commands = const [];
  List<PumpSchedule> _schedules = const [];
  List<DeviceAlert> _alerts = const [];
  Map<String, dynamic> _alertSettings = const {};
  bool _isLoading = true;
  bool _isSendingCommand = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  PumpMode _pumpMode = PumpMode.auto;
  Timer? _manualModeReminderTimer;
  Timer? _pumpCountdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _device = widget.device;
    _loadDeviceData();
    if (widget.initialSensor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSensorHistory(widget.initialSensor!);
      });
    }
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _loadDeviceData(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _manualModeReminderTimer?.cancel();
    _pumpCountdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeviceData({bool showLoading = true}) async {
    if (_isSendingCommand && showLoading) return;
    if (mounted) {
      setState(() {
        if (showLoading && _readings.isEmpty) _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        _apiService.getDevice(widget.device.id),
        _apiService.getDeviceReadings(widget.device.id, limit: 60),
        _apiService.getPumpCommands(widget.device.id, pageSize: 10),
        _apiService.getPumpSchedules(widget.device.id),
        _apiService.getAlerts(widget.device.id, status: 'active'),
        _apiService.getAlertSettings(widget.device.id),
      ]);
      if (!mounted) return;

      final deviceData = results[0] as Map<String, dynamic>;
      final readingsData = results[1] as List<dynamic>;
      final commandsData = results[2] as Map<String, dynamic>;
      final schedulesData = results[3] as List<dynamic>;
      final alertsData = results[4] as Map<String, dynamic>;
      final commandItems = commandsData['items'] as List<dynamic>? ?? [];
      final alertItems = alertsData['items'] as List<dynamic>? ?? [];
      final readings = readingsData
          .map((item) => SensorReading.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _device = Device.fromJson(deviceData);
        _readings = readings;
        _commands = commandItems
            .map((item) => PumpCommand.fromJson(item as Map<String, dynamic>))
            .toList();
        _schedules = schedulesData
            .map((item) => PumpSchedule.fromJson(item as Map<String, dynamic>))
            .toList();
        _alerts = alertItems
            .map((item) => DeviceAlert.fromJson(item as Map<String, dynamic>))
            .toList();
        _alertSettings = results[5] as Map<String, dynamic>;
        _lastUpdated = readings.isNotEmpty
            ? DateTime.tryParse(readings.first.recordedAt)
            : DateTime.tryParse(_device.lastSeenAt ?? '');
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  PumpCommand? get _latestCommand => _commands.isEmpty ? null : _commands.first;

  bool get _isPumpRunning {
    final command = _latestCommand;
    final acknowledgedAt = DateTime.tryParse(command?.acknowledgedAt ?? '');
    return command?.status == 'Acknowledged' &&
        command?.acknowledgedIsOn == true &&
        acknowledgedAt != null &&
        acknowledgedAt
            .add(Duration(seconds: command!.durationSeconds))
            .isAfter(DateTime.now().toUtc());
  }

  bool get _isCommandPending {
    if (_isSendingCommand) return true;
    final command = _latestCommand;
    if (command?.status != 'Pending') return false;
    final issuedAt = DateTime.tryParse(command!.issuedAt);
    return issuedAt != null &&
        DateTime.now().toUtc().difference(issuedAt).inMinutes < 2;
  }

  DateTime? _getNextScheduleTime() {
    final enabled = _enabledSchedules;
    if (enabled.isEmpty) return null;

    final now = DateTime.now();
    final today = now.weekday == 7 ? 0 : now.weekday;

    for (final schedule in enabled) {
      if ((schedule.weekdayMask & (1 << today)) != 0) {
        final parts = schedule.startTime.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final scheduleTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          if (scheduleTime.isAfter(now)) {
            return scheduleTime;
          }
        }
      }
    }

    return null;
  }

  String _formatTimeRemaining(DateTime? time) {
    if (time == null) return 'Không có lịch';
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.isNegative) return 'Đã qua';

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')} phút';
  }

  void _startManualModeReminder() {
    _manualModeReminderTimer?.cancel();
    _manualModeReminderTimer = Timer(const Duration(minutes: 30), () {
      if (mounted && _pumpMode == PumpMode.manual && !_isPumpRunning) {
        _showManualModeReminder();
      }
    });
  }

  void _stopManualModeReminder() {
    _manualModeReminderTimer?.cancel();
  }

  void _showManualModeReminder() {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Chế độ Thủ công'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${_device.name} đang ở chế độ Thủ công và chưa phun. Chuyển về Tự động?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Giữ Thủ công'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() => _pumpMode = PumpMode.auto);
            },
            child: const Text('Chuyển Tự động'),
          ),
        ],
      ),
    );
  }

  void _startPumpCountdown(int durationSeconds) {
    _remainingSeconds = durationSeconds;
    _pumpCountdownTimer?.cancel();
    _pumpCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
          }
        });
      }
    });
  }

  void _stopPumpCountdown() {
    _pumpCountdownTimer?.cancel();
    _remainingSeconds = 0;
  }

  List<PumpSchedule> get _enabledSchedules =>
      _schedules.where((schedule) => schedule.isEnabled).toList();

  Future<void> _sendPumpCommand({int? durationSeconds}) async {
    if (!_device.isOnline || _isCommandPending) return;
    setState(() => _isSendingCommand = true);
    try {
      await _apiService.sendPumpCommand(
        _device.id,
        ApiService.generatePumpCommandId(),
        !_isPumpRunning,
        durationSeconds ?? (_isPumpRunning ? null : 60),
      );
      if (durationSeconds != null && durationSeconds > 0) {
        _startPumpCountdown(durationSeconds);
      }
      await _loadDeviceData(showLoading: false);
      if (mounted && durationSeconds != null && durationSeconds > 0) {
        HapticFeedback.lightImpact();
      }
    } catch (error) {
      if (mounted) _showMessage('Không thể gửi lệnh: $error');
    } finally {
      if (mounted) setState(() => _isSendingCommand = false);
    }
  }

  Future<void> _switchPumpMode(PumpMode mode) async {
    if (mode == PumpMode.manual && _pumpMode == PumpMode.auto) {
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Chuyển sang Thủ công'),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Lịch tự động sẽ tạm dừng. Bạn có chắc?'),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              isDestructiveAction: true,
              child: const Text('Chuyển'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _pumpMode = mode);

    if (mode == PumpMode.manual) {
      _startManualModeReminder();
    } else {
      _stopManualModeReminder();
    }
  }

  Future<void> _showManualDurationDialog() async {
    final duration = await showCupertinoModalPopup<int>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: const Text('Chọn thời gian chạy'),
        message: const Text('Bơm sẽ tự động tắt sau thời gian đã chọn'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(30),
            child: const Text('30 giây'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(60),
            child: const Text('1 phút'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(300),
            child: const Text('5 phút'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(600),
            child: const Text('10 phút'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(popupContext).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );

    if (duration != null && mounted) {
      await _sendPumpCommand(durationSeconds: duration);
    }
  }

  Future<void> _openSchedules() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => CupertinoPumpSchedulesScreen(device: _device),
      ),
    );
    if (mounted) await _loadDeviceData(showLoading: false);
  }

  Future<void> _openSensorHistory(String sensor) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => SensorHistoryScreen(device: _device, sensor: sensor),
      ),
    );
  }

  Future<void> _openAlerts() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(builder: (_) => AlertsScreen(device: _device)),
    );
    if (mounted) await _loadDeviceData(showLoading: false);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) =>
            DeviceSettingsScreen(device: _device, apiService: _apiService),
      ),
    );
    if (mounted) await _loadDeviceData(showLoading: false);
  }

  void _showMessage(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _readings.isEmpty && _errorMessage == null) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: _returnButton(context),
          middle: Text('Thiết bị'),
        ),
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    if (_errorMessage != null && _readings.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: _returnButton(context),
          middle: Text(_device.name),
        ),
        child: SafeArea(
          child: _DetailError(
            message: _errorMessage!,
            onRetry: _loadDeviceData,
          ),
        ),
      );
    }

    final reading = _readings.isEmpty ? null : _readings.first;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _returnButton(context),
        middle: Text(
          _device.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openSettings,
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: () => _loadDeviceData()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              sliver: SliverList.list(
                children: [
                  DeviceHeader(
                    device: _device,
                    lastUpdated: _lastUpdated,
                    scheduleContinuesOffline:
                        !_device.isOnline && _enabledSchedules.isNotEmpty,
                  ),
                  const SizedBox(height: 24),
                  _DetailSectionTitle(
                    title: 'Cảm biến',
                    subtitle: reading == null ? 'Không có dữ liệu mới' : null,
                  ),
                  const SizedBox(height: 12),
                  SensorGrid(
                    reading: reading,
                    waterLevelThreshold:
                        (_alertSettings['lowWaterLevelPercent'] as num?)
                            ?.toDouble() ??
                        30,
                    highTemperatureThreshold:
                        (_alertSettings['highTemperatureC'] as num?)
                            ?.toDouble() ??
                        30,
                    isOffline: !_device.isOnline,
                    onSensorTap: _openSensorHistory,
                  ),
                  const SizedBox(height: 20),
                  PumpControlCard(
                    isOnline: _device.isOnline,
                    isRunning: _isPumpRunning,
                    isSending: _isCommandPending,
                    pumpMode: _pumpMode,
                    nextScheduleTime: _getNextScheduleTime(),
                    remainingSeconds: _remainingSeconds,
                    onModeChange: _switchPumpMode,
                    onManualToggle: _showManualDurationDialog,
                    onStop: () => _sendPumpCommand(),
                  ),
                  const SizedBox(height: 16),
                  ScheduleSummaryCard(
                    schedules: _schedules,
                    isOffline: !_device.isOnline,
                    onEdit: _openSchedules,
                  ),
                  const SizedBox(height: 16),
                  HistoryPreviewCard(
                    readings: _readings,
                    onTap: () => _openSensorHistory('temperature'),
                  ),
                  const SizedBox(height: 16),
                  AlertsSummaryCard(
                    alerts: _alerts,
                    device: _device,
                    onTap: _openAlerts,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _returnButton(BuildContext context) => Navigator.canPop(context)
      ? CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        )
      : null;
}

class DeviceHeader extends StatelessWidget {
  final Device device;
  final DateTime? lastUpdated;
  final bool scheduleContinuesOffline;

  const DeviceHeader({
    super.key,
    required this.device,
    required this.lastUpdated,
    required this.scheduleContinuesOffline,
  });

  @override
  Widget build(BuildContext context) {
    final online = device.isOnline;
    final tint = online
        ? AerogreenCupertinoTheme.aerogreenPrimary.withValues(alpha: 0.11)
        : CupertinoColors.systemGrey5.resolveFrom(context);
    final accent = online
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemGrey;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  device.name,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DeviceStatusChip(isOnline: online),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                online ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                color: accent,
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                online ? 'Kết nối ổn định' : 'Thiết bị ngoại tuyến',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                lastUpdated == null
                    ? 'Chưa có dữ liệu'
                    : 'Cập nhật ${DateFormat('HH:mm').format(lastUpdated!.toLocal())}',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (scheduleContinuesOffline) ...[
            const SizedBox(height: 12),
            const Text(
              'Lịch tự động vẫn tiếp tục chạy khi thiết bị ngoại tuyến.',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DeviceStatusChip extends StatelessWidget {
  final bool isOnline;

  const DeviceStatusChip({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline
        ? AerogreenCupertinoTheme.aerogreenPrimary
        : CupertinoColors.systemGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SensorGrid extends StatelessWidget {
  final SensorReading? reading;
  final double waterLevelThreshold;
  final double highTemperatureThreshold;
  final bool isOffline;
  final ValueChanged<String> onSensorTap;

  const SensorGrid({
    super.key,
    required this.reading,
    required this.waterLevelThreshold,
    required this.highTemperatureThreshold,
    required this.isOffline,
    required this.onSensorTap,
  });

  @override
  Widget build(BuildContext context) {
    final specs = [
      _SensorSpec(
        keyName: 'temperature',
        label: 'Nhiệt độ',
        value: reading?.temperature,
        unit: '°C',
        icon: CupertinoIcons.thermometer,
        warning: (reading?.temperature ?? 0) >= highTemperatureThreshold,
        color: CupertinoColors.systemOrange,
      ),
      _SensorSpec(
        keyName: 'humidity',
        label: 'Độ ẩm',
        value: reading?.humidity,
        unit: '%',
        icon: CupertinoIcons.drop_fill,
        warning: (reading?.humidity ?? 0) < 30,
        color: CupertinoColors.systemBlue,
      ),
      _SensorSpec(
        keyName: 'ph',
        label: 'pH',
        value: reading?.ph,
        unit: '',
        icon: CupertinoIcons.info_circle,
        warning: (reading?.ph ?? 7) < 5.5 || (reading?.ph ?? 7) > 7.5,
        color: CupertinoColors.systemPurple,
      ),
      _SensorSpec(
        keyName: 'waterLevel',
        label: 'Mực nước',
        value: reading?.waterLevel,
        unit: '%',
        icon: CupertinoIcons.drop_triangle_fill,
        warning: (reading?.waterLevel ?? 100) < waterLevelThreshold,
        color: CupertinoColors.systemTeal,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 580
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) => _SensorCard(
            spec: specs[index],
            isOffline: isOffline,
            onTap: () => onSensorTap(specs[index].keyName),
          ),
        );
      },
    );
  }
}

class _SensorSpec {
  final String keyName;
  final String label;
  final double? value;
  final String unit;
  final IconData icon;
  final bool warning;
  final Color color;

  const _SensorSpec({
    required this.keyName,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.warning,
    required this.color,
  });
}

class _SensorCard extends StatelessWidget {
  final _SensorSpec spec;
  final bool isOffline;
  final VoidCallback onTap;

  const _SensorCard({
    required this.spec,
    required this.isOffline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = spec.value != null;
    final color = isOffline || !hasValue
        ? CupertinoColors.systemGrey
        : spec.warning
        ? CupertinoColors.systemOrange
        : spec.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? spec.icon : CupertinoIcons.exclamationmark_circle,
              color: color,
              size: 23,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    spec.label,
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasValue
                        ? '${spec.value!.toStringAsFixed(1)} ${spec.unit}'
                              .trim()
                        : 'Không có dữ liệu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.tertiaryLabel,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class PumpControlCard extends StatelessWidget {
  final bool isOnline;
  final bool isRunning;
  final bool isSending;
  final PumpMode pumpMode;
  final DateTime? nextScheduleTime;
  final int remainingSeconds;
  final ValueChanged<PumpMode>? onModeChange;
  final VoidCallback? onManualToggle;
  final VoidCallback? onStop;
  final VoidCallback? onPressed;

  const PumpControlCard({
    super.key,
    required this.isOnline,
    required this.isRunning,
    required this.isSending,
    this.pumpMode = PumpMode.manual,
    this.nextScheduleTime,
    this.remainingSeconds = 0,
    this.onModeChange,
    this.onManualToggle,
    this.onStop,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => _DetailSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isRunning ? CupertinoIcons.power : CupertinoIcons.power,
              color: isOnline
                  ? (isRunning
                        ? CupertinoColors.systemOrange
                        : AerogreenCupertinoTheme.aerogreenPrimary)
                  : CupertinoColors.systemGrey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DetailSectionTitle(title: 'Điều khiển bơm'),
                  const SizedBox(height: 3),
                  Text(
                    !isOnline
                        ? 'Không khả dụng khi ngoại tuyến'
                        : isSending
                        ? 'Đang gửi lệnh…'
                        : isRunning
                        ? 'Bơm đang chạy'
                        : 'Bơm đang tắt',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoSlidingSegmentedControl<PumpMode>(
          groupValue: pumpMode,
          children: const {
            PumpMode.auto: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Tự động'),
            ),
            PumpMode.manual: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Thủ công'),
            ),
          },
          onValueChanged: (value) {
            if (isOnline && value != null) onModeChange?.call(value);
          },
        ),
        const SizedBox(height: 16),
        if (pumpMode == PumpMode.auto) ...[
          if (nextScheduleTime != null)
            Row(
              children: [
                const Icon(
                  CupertinoIcons.clock,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lần phun tiếp theo sau ${_formatTimeRemaining(nextScheduleTime)}',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 13,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Không có lịch phun được kích hoạt',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
        ] else ...[
          if (isRunning) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.play_fill,
                  size: 16,
                  color: CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bơm đang chạy - còn ${_formatCountdown(remainingSeconds)}',
                  style: const TextStyle(
                    color: CupertinoColors.systemOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: isOnline && !isSending
                      ? (onStop ?? onPressed)
                      : null,
                  child: isSending
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                          radius: 8,
                        )
                      : const Text('Dừng', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ] else ...[
            CupertinoButton.filled(
              onPressed: isOnline && !isSending
                  ? (onManualToggle ?? onPressed)
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: isSending
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : const Text(
                      'BẬT BƠM',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ],
      ],
    ),
  );

  String _formatCountdown(int seconds) {
    if (seconds <= 0) return '00:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTimeRemaining(DateTime? time) {
    if (time == null) return 'Không có lịch';
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.isNegative) return 'Đã qua';

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')} phút';
  }
}

class ScheduleSummaryCard extends StatelessWidget {
  final List<PumpSchedule> schedules;
  final bool isOffline;
  final VoidCallback onEdit;

  const ScheduleSummaryCard({
    super.key,
    required this.schedules,
    required this.isOffline,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = schedules.where((schedule) => schedule.isEnabled).toList();
    return _DetailSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _DetailSectionTitle(title: 'Lịch tưới')),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onEdit,
                child: const Text('Sửa'),
              ),
            ],
          ),
          if (enabled.isEmpty)
            const Text(
              'Chưa có lịch tự động.',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            )
          else ...[
            for (final schedule in enabled.take(2))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Phun ${schedule.durationSeconds} giây mỗi ${schedule.intervalMinutes ?? 5} phút, ${_scheduleTime(schedule.startTime)}-${_scheduleEndTime(schedule.startTime, schedule.durationSeconds)}',
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 13,
                  ),
                ),
              ),
          ],
          if (isOffline && enabled.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Lịch đã lưu tiếp tục chạy tự động khi có kết nối.',
              style: TextStyle(
                color: CupertinoColors.systemOrange,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HistoryPreviewCard extends StatelessWidget {
  final List<SensorReading> readings;
  final VoidCallback onTap;

  const HistoryPreviewCard({
    super.key,
    required this.readings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    final points = readings
        .where((reading) {
          final recorded = DateTime.tryParse(reading.recordedAt);
          return recorded != null &&
              recorded.isAfter(cutoff) &&
              reading.temperature != null;
        })
        .toList()
        .reversed
        .toList();
    return GestureDetector(
      onTap: onTap,
      child: _DetailSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailSectionTitle(title: 'Lịch sử 24 giờ'),
            const SizedBox(height: 12),
            if (points.length < 2)
              const SizedBox(
                height: 70,
                child: Center(
                  child: Text(
                    'Chưa đủ dữ liệu để tạo biểu đồ.',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                ),
              )
            else
              SizedBox(
                height: 76,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (points.length - 1).toDouble(),
                    minY:
                        points
                            .map((reading) => reading.temperature!)
                            .reduce(math.min) -
                        1,
                    maxY:
                        points
                            .map((reading) => reading.temperature!)
                            .reduce(math.max) +
                        1,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var index = 0; index < points.length; index++)
                            FlSpot(
                              index.toDouble(),
                              points[index].temperature!,
                            ),
                        ],
                        isCurved: true,
                        color: AerogreenCupertinoTheme.aerogreenPrimary,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AerogreenCupertinoTheme.aerogreenPrimary
                              .withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              '${points.length} lần ghi · Nhiệt độ',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertsSummaryCard extends StatelessWidget {
  final List<DeviceAlert> alerts;
  final Device device;
  final VoidCallback onTap;

  const AlertsSummaryCard({
    super.key,
    required this.alerts,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: _DetailSurface(
      child: Row(
        children: [
          Icon(
            alerts.isEmpty
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_triangle_fill,
            color: alerts.isEmpty
                ? AerogreenCupertinoTheme.aerogreenPrimary
                : CupertinoColors.systemOrange,
            size: 21,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DetailSectionTitle(title: 'Cảnh báo'),
                const SizedBox(height: 3),
                Text(
                  alerts.isEmpty
                      ? 'Không có cảnh báo đang mở.'
                      : '${alerts.length} cảnh báo đang mở',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (alerts.isNotEmpty)
            Text(
              alerts.first.type == 'LOW_WATER_LEVEL'
                  ? 'Mực nước thấp'
                  : 'Nhiệt độ cao',
              style: const TextStyle(
                color: CupertinoColors.systemOrange,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    ),
  );
}

class DeviceSettingsScreen extends StatefulWidget {
  final Device device;
  final ApiService apiService;

  const DeviceSettingsScreen({
    super.key,
    required this.device,
    required this.apiService,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  final _temperatureController = TextEditingController();
  final _waterController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await widget.apiService.getAlertSettings(
        widget.device.id,
      );
      if (!mounted) return;
      _temperatureController.text =
          settings['highTemperatureC']?.toString() ?? '';
      _waterController.text =
          settings['lowWaterLevelPercent']?.toString() ?? '';
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final temperature = _temperatureController.text.trim().isEmpty
        ? null
        : double.tryParse(_temperatureController.text.trim());
    final water = _waterController.text.trim().isEmpty
        ? null
        : double.tryParse(_waterController.text.trim());
    if ((_temperatureController.text.trim().isNotEmpty &&
            temperature == null) ||
        (_waterController.text.trim().isNotEmpty && water == null) ||
        (water != null && (water < 0 || water > 100))) {
      setState(
        () => _errorMessage = 'Kiểm tra lại ngưỡng nhiệt độ và mực nước.',
      );
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await widget.apiService.updateAlertSettings(
        widget.device.id,
        highTemperatureC: temperature,
        lowWaterLevelPercent: water,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(
      middle: Text('Cài đặt thiết bị'),
    ),
    child: SafeArea(
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingsField(
                  label: 'Cảnh báo nhiệt độ cao (°C)',
                  controller: _temperatureController,
                ),
                const SizedBox(height: 16),
                _SettingsField(
                  label: 'Cảnh báo mực nước thấp (%)',
                  controller: _waterController,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                ],
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text('Lưu cài đặt'),
                ),
              ],
            ),
    ),
  );
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _SettingsField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 7, left: 4),
        child: Text(
          label,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      CupertinoTextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ],
  );
}

class _DetailSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _DetailSectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (subtitle != null)
        Text(
          subtitle!,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 11,
          ),
        ),
    ],
  );
}

class _DetailSurface extends StatelessWidget {
  final Widget child;

  const _DetailSurface({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(17),
    ),
    child: child,
  );
}

class _DetailError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemOrange,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text('Không thể tải chi tiết thiết bị'),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}

String _scheduleTime(String value) {
  final parts = value.split(':');
  return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : value;
}

String _scheduleEndTime(String startTime, int durationSeconds) {
  final parts = startTime.split(':');
  if (parts.length < 2) return startTime;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final totalMinutes = hour * 60 + minute + (durationSeconds / 60).ceil();
  final endHour = (totalMinutes ~/ 60) % 24;
  final endMinute = totalMinutes % 60;
  return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

String _scheduleDays(int mask) {
  const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  final selected = [
    for (var day = 0; day < days.length; day++)
      if ((mask & (1 << day)) != 0) days[day],
  ];
  return selected.isEmpty ? 'chưa chọn ngày' : selected.join(', ');
}
