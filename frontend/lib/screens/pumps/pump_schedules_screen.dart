import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../models/pump_schedule.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_buttons.dart';

class PumpSchedulesScreen extends StatefulWidget {
  final Device device;

  const PumpSchedulesScreen({super.key, required this.device});

  @override
  State<PumpSchedulesScreen> createState() => _PumpSchedulesScreenState();
}

class _PumpSchedulesScreenState extends State<PumpSchedulesScreen> {
  final ApiService _apiService = ApiService();
  List<PumpSchedule> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedulesData = await _apiService.getPumpSchedules(
        widget.device.id,
      );
      setState(() {
        _schedules = schedulesData
            .map((data) => PumpSchedule.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddScheduleDialog(),
    );

    if (result != null) {
      try {
        await _apiService.createPumpSchedule(
          widget.device.id,
          result['startTime'] as String,
          result['durationSeconds'] as int,
          result['daysOfWeek'] as List<int>,
          endTime: result['endTime'] as String?,
          intervalMinutes: result['intervalMinutes'] as int?,
          activeFromDate: result['activeFromDate'] as DateTime?,
          activeUntilDate: result['activeUntilDate'] as DateTime?,
        );
        await _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm lịch trình thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteSchedule(PumpSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa lịch trình này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deletePumpSchedule(widget.device.id, schedule.id);
        await _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa lịch trình thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = TimeOfDay.fromDateTime(DateTime.parse(timeString));
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  String _formatDays(List<int> days) {
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days.map((day) => dayNames[day]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en'),
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: Theme(
        data: ThemeData(useMaterial3: true),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Lịch trình bơm - ${widget.device.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSchedules,
              ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: _addSchedule,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải lịch trình...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _loadSchedules);
    }

    if (_schedules.isEmpty) {
      return EmptyState(
        icon: Icons.schedule,
        title: 'Chưa có lịch trình nào',
        subtitle: 'Thêm lịch trình bơm tự động',
        action: CustomElevatedButton(
          text: 'Thêm lịch trình',
          icon: Icons.add,
          onPressed: _addSchedule,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Switch(value: schedule.isEnabled, onChanged: (enabled) async { await _apiService.updatePumpSchedule(widget.device.id, schedule, isEnabled: enabled); await _loadSchedules(); }),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(schedule.startTime),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSchedule(schedule),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thời gian: ${schedule.durationSeconds} giây',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lặp lại: ${_formatDays(schedule.daysOfWeek)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (schedule.activeFromDate != null || schedule.activeUntilDate != null)
                    Text('Hiệu lực: ${schedule.activeFromDate ?? 'ngay'} đến ${schedule.activeUntilDate ?? 'vô thời hạn'}'),
                  if (schedule.isActive) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime? _activeFromDate;
  DateTime? _activeUntilDate;
  final _durationController = TextEditingController(text: '60');
  final List<int> _selectedDays = [1, 2, 3, 4, 5]; // T2-T6 mặc định

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _selectDate({required bool isStart}) async {
    final picked = await showDatePicker(context: context, initialDate: isStart ? (_activeFromDate ?? DateTime.now()) : (_activeUntilDate ?? _activeFromDate ?? DateTime.now()), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) setState(() { if (isStart) { _activeFromDate = picked; } else { _activeUntilDate = picked; } });
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return AlertDialog(
      title: const Text('Thêm lịch trình bơm'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giờ thiết bị: Asia/Ho_Chi_Minh. Lịch ưu tiên hơn điều khiển thủ công.'),
              // Time picker
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Giờ bắt đầu',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async { final picked = await showTimePicker(context: context, initialTime: _endTime); if (picked != null) setState(() => _endTime = picked); },
                child: InputDecorator(decoration: const InputDecoration(labelText: 'Giờ kết thúc khung tự động', border: OutlineInputBorder()), child: Text('${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}')),
              ),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: OutlinedButton(onPressed: () => _selectDate(isStart: true), child: Text(_activeFromDate == null ? 'Từ ngày' : '${_activeFromDate!.day}/${_activeFromDate!.month}/${_activeFromDate!.year}'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => _selectDate(isStart: false), child: Text(_activeUntilDate == null ? 'Đến ngày' : '${_activeUntilDate!.day}/${_activeUntilDate!.month}/${_activeUntilDate!.year}')))]),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian (giây)',
                  border: OutlineInputBorder(),
                  hintText: '60',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thời gian';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Thời gian phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Days of week
              const Text('Lặp lại:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(dayNames[index]),
                    selected: _selectedDays.contains(index),
                    onSelected: (selected) => _toggleDay(index),
                    selectedColor: Colors.green.withValues(alpha: 0.3),
                    checkmarkColor: Colors.green,
                  );
                }),
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
              String wallClock(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

              Navigator.pop(context, {
                'startTime': wallClock(_selectedTime),
                'durationSeconds': int.parse(_durationController.text),
                'daysOfWeek': _selectedDays,
                'endTime': wallClock(_endTime),
                'intervalMinutes': 60,
                'activeFromDate': _activeFromDate,
                'activeUntilDate': _activeUntilDate,
              });
            } else if (_selectedDays.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng chọn ít nhất một ngày'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
