import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/section_chip.dart';
import '../models/device.dart';
import '../models/pump_schedule.dart';
import '../providers/data_providers.dart';
import '../services/api_service.dart';

class ControlCenterScreen extends ConsumerStatefulWidget {
  const ControlCenterScreen({super.key});

  @override
  ConsumerState<ControlCenterScreen> createState() => _ControlCenterScreenState();
}

class _ControlCenterScreenState extends ConsumerState<ControlCenterScreen> {
  final _api = ApiService();
  _ControlData? _data;
  bool _loading = true;
  bool _pending = false;
  String? _error;
  double _duration = 30;
  final Set<String> _pausedByThisScreen = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final devices = (await _api.getDevices()).map((raw) => Device.fromJson(raw as Map<String, dynamic>)).toList();
      if (devices.isEmpty) throw StateError('Chưa có thiết bị nào được kết nối.');
      final device = devices.first;
      final schedules = (await _api.getPumpSchedules(device.id)).map((raw) => PumpSchedule.fromJson(raw as Map<String, dynamic>)).toList();
      if (mounted) setState(() => _data = _ControlData(device, schedules));
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeMode(String mode) async {
    if (_pending || _data == null || ref.read(controlModeProvider) == mode) return;
    final data = _data!;
    setState(() => _pending = true);
    try {
      if (mode == 'manual') {
        final enabled = data.schedules.where((item) => item.isEnabled).toList();
        final paused = <PumpSchedule>[];
        try {
          for (final schedule in enabled) { await _api.updatePumpSchedule(data.device.id, schedule, isEnabled: false); paused.add(schedule); }
        } catch (_) {
          for (final schedule in paused) { try { await _api.updatePumpSchedule(data.device.id, schedule, isEnabled: true); } catch (_) {} }
          rethrow;
        }
        _pausedByThisScreen..clear()..addAll(paused.map((item) => item.id));
      } else {
        for (final schedule in data.schedules.where((item) => _pausedByThisScreen.contains(item.id))) {
          await _api.updatePumpSchedule(data.device.id, schedule, isEnabled: true);
        }
        _pausedByThisScreen.clear();
      }
      ref.read(controlModeProvider.notifier).state = mode;
      await _load();
    } catch (error) { _message('Không thể cập nhật chế độ tự động: $error'); }
    finally { if (mounted) setState(() => _pending = false); }
  }

  Future<void> _mistNow() async {
    final data = _data;
    if (data == null || _pending || !data.device.isOnline) return;
    setState(() => _pending = true);
    try {
      final readings = await _api.getDeviceReadings(data.device.id, limit: 1);
      final waterLevel = readings.isEmpty ? null : (readings.first as Map<String, dynamic>)['waterLevel'] as num?;
      final settings = await _api.getAlertSettings(data.device.id);
      final threshold = (settings['lowWaterLevelPercent'] as num?)?.toDouble() ?? 30;
      if (waterLevel != null && waterLevel.toDouble() < threshold) {
        _message('Không thể bật bơm khi mực nước đang thấp.');
        return;
      }
      await _api.sendPumpCommand(data.device.id, ApiService.generatePumpCommandId(), true, _duration.round());
      _message('Đã gửi lệnh phun. Trạng thái vật lý sẽ cập nhật khi thiết bị xác nhận.');
    } catch (error) { _message('Không thể gửi lệnh bơm: $error'); }
    finally { if (mounted) setState(() => _pending = false); }
  }

  void _message(String value) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); }

  @override
  Widget build(BuildContext context) {
    final smart = ref.watch(controlModeProvider) == 'smart';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeader(chip: SectionChip(label: 'Thiết bị'), title: 'Trung tâm Điều khiển', subtitle: 'Điều khiển bơm theo lịch hoặc thao tác thủ công an toàn.'),
          const SizedBox(height: 20),
          _ModeToggle(smart: smart, pending: _pending, onChanged: _changeMode),
          const SizedBox(height: 18),
          Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? _Unavailable(message: _error!, onRetry: _load) : RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: smart ? _SmartContent(data: _data!, pending: _pending) : _ManualContent(data: _data!, pending: _pending, duration: _duration, onDuration: (value) => setState(() => _duration = value), onMist: _mistNow)))),
        ]),
      )),
    );
  }
}

class _ControlData { const _ControlData(this.device, this.schedules); final Device device; final List<PumpSchedule> schedules; }

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.smart, required this.pending, required this.onChanged}); final bool smart; final bool pending; final ValueChanged<String> onChanged;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.rowBackground, borderRadius: BorderRadius.circular(28)), child: Row(children: [_tab('✦  Thông minh', 'smart', smart), _tab('⚙  Thủ công', 'manual', !smart)]));
  Widget _tab(String text, String mode, bool selected) {
    return Expanded(
      child: InkWell(
        onTap: pending ? null : () => onChanged(mode),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected ? const [BoxShadow(color: Color(0x182F5D3F), blurRadius: 8)] : null,
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.forestGreen : AppColors.secondaryText)),
        ),
      ),
    );
  }
}

class _SmartContent extends StatelessWidget {
  const _SmartContent({required this.data, required this.pending}); final _ControlData data; final bool pending;
  @override Widget build(BuildContext context) {
    final active = data.schedules.where((item) => item.isEnabled).toList();
    final status = !data.device.isOnline ? 'Thiết bị ngoại tuyến' : active.isEmpty ? 'Đang chờ lịch được bật' : 'Tự động đang hoạt động';
    return Column(children: [
      _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.auto_awesome, color: AppColors.forestGreen), const SizedBox(width: 10), const Expanded(child: Text('Trạng thái tự động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), _Status(text: status, healthy: data.device.isOnline && active.isNotEmpty)]), const SizedBox(height: 12), Text(data.device.isOnline ? 'Lịch bơm được quản lý bởi thiết bị và backend.' : 'Không gửi được lệnh khi thiết bị chưa trực tuyến.', style: const TextStyle(color: AppColors.secondaryText))])),
      const SizedBox(height: 14),
      _Card(child: const _UnavailableLight()), const SizedBox(height: 14),
      _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.water_drop_outlined, color: AppColors.forestGreen), SizedBox(width: 10), Text('Máy bơm nước', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]), const SizedBox(height: 10), if (active.isEmpty) const Text('Chưa có lịch bơm đang bật.') else ...active.map((schedule) => InfoRow(label: 'LỊCH TƯỚI', value: '${schedule.startTime} · ${schedule.durationSeconds}s${schedule.intervalMinutes == null ? '' : ' · mỗi ${schedule.intervalMinutes} phút'}'))])),
    ]);
  }
}

class _ManualContent extends StatelessWidget {
  const _ManualContent({required this.data, required this.pending, required this.duration, required this.onDuration, required this.onMist}); final _ControlData data; final bool pending; final double duration; final ValueChanged<double> onDuration; final VoidCallback onMist;
  @override Widget build(BuildContext context) => Column(children: [
    _Card(child: const _UnavailableLight()), const SizedBox(height: 14),
    _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.water_drop_outlined, color: AppColors.forestGreen), const SizedBox(width: 10), const Expanded(child: Text('Máy bơm nước', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), _Status(text: data.device.isOnline ? 'Sẵn sàng' : 'Ngoại tuyến', healthy: data.device.isOnline)]), const SizedBox(height: 8), const Text('Thời gian phun sương', style: TextStyle(color: AppColors.secondaryText)), Row(children: [const Text('5s'), Expanded(child: Slider(min: 5, max: 600, divisions: 119, value: duration, activeColor: AppColors.forestGreen, onChanged: pending || !data.device.isOnline ? null : onDuration)), Text('${duration.round()}s')]), SizedBox(width: double.infinity, child: GradientButton(label: pending ? 'Đang gửi lệnh...' : 'Phun ngay', isLoading: pending, onPressed: data.device.isOnline && !pending ? onMist : null))])),
    const SizedBox(height: 16), const Text('Chế độ thủ công đã tạm dừng các lịch bơm do màn hình này quản lý. Bạn có thể chuyển lại bất cứ lúc nào.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
  ]);
}

class _UnavailableLight extends StatelessWidget { const _UnavailableLight(); @override Widget build(BuildContext context) => Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFE3A72F)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Đèn trồng cây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), Text('Chưa khả dụng — backend hiện chưa cung cấp API điều khiển hoặc lịch cho đèn.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))])), const _Status(text: 'Chưa hỗ trợ', healthy: false)]); }
class _Card extends StatelessWidget { const _Card({required this.child}); final Widget child; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: child)); }
class _Status extends StatelessWidget { const _Status({required this.text, required this.healthy}); final String text; final bool healthy; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: (healthy ? AppColors.mintChip : const Color(0xFFFFE6C5)), borderRadius: BorderRadius.circular(16)), child: Text(text, style: TextStyle(fontSize: 11, color: healthy ? AppColors.forestGreen : const Color(0xFF8A5A00)))); }
class _Unavailable extends StatelessWidget { const _Unavailable({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_outlined, size: 42, color: AppColors.secondaryText), const SizedBox(height: 12), Text('Không tải được trạng thái thiết bị', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton(onPressed: onRetry, child: const Text('Thử lại'))])); }
