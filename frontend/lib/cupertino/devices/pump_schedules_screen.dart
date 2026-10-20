import '../../utils/display_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/device.dart';
import '../../models/pump_schedule.dart';
import '../../services/api_service.dart';
import '../../utils/l10n.dart';

enum SchedulePreset {
  seedlings('Cây giống', 10, 15),
  leafy('Rau lá', 20, 30),
  herbs('Thảo mộc', 15, 20),
  custom('Tùy chỉnh', 30, 30);

  String localizedLabel(BuildContext context) => switch (this) {
    SchedulePreset.seedlings => context.l10n.seedlingsPreset,
    SchedulePreset.leafy => context.l10n.leafyPreset,
    SchedulePreset.herbs => context.l10n.herbsPreset,
    SchedulePreset.custom => context.l10n.customize,
  };

  final String label;
  final int defaultMistLength;
  final int defaultInterval;

  const SchedulePreset(
    this.label,
    this.defaultMistLength,
    this.defaultInterval,
  );
}

class CupertinoPumpSchedulesScreen extends StatefulWidget {
  final Device device;

  const CupertinoPumpSchedulesScreen({super.key, required this.device});

  @override
  State<CupertinoPumpSchedulesScreen> createState() =>
      _CupertinoPumpSchedulesScreenState();
}

class _CupertinoPumpSchedulesScreenState
    extends State<CupertinoPumpSchedulesScreen> {
  final ApiService _apiService = ApiService();
  List<PumpSchedule> _schedules = [];
  bool _isLoading = true;
  String Function()? _errorMessage;

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
        _errorMessage = () => localizedApiError(e, context.l10n);
        _isLoading = false;
      });
    }
  }

  Future<void> _addSchedule() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      CupertinoPageRoute(
        builder: (_) => AddScheduleDialog(device: widget.device),
      ),
    );

    if (result != null && mounted) {
      await _loadSchedules();
    }
  }

  Future<void> _deleteSchedule(PumpSchedule schedule) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.l10n.confirmDeletion),
        content: Text(context.l10n.deleteScheduleConfirmation),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deletePumpSchedule(widget.device.id, schedule.id);
        if (mounted) await _loadSchedules();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(context.l10n.error),
              content: Text(
                context.l10n.deleteScheduleFailed(
                  localizedApiError(e, context.l10n),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.dismiss),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: Text(context.l10n.wateringScheduleFor(widget.device.name)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _addSchedule,
              child: const Icon(CupertinoIcons.add),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _loadSchedules,
              child: const Icon(CupertinoIcons.arrow_2_circlepath),
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: _loadSchedules),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CupertinoActivityIndicator(radius: 14)),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: CupertinoColors.systemOrange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.scheduleLoadError,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!(),
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        onPressed: _loadSchedules,
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (_schedules.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 48,
                        color: CupertinoColors.systemGrey2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.noSchedulesYet,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.addAutomaticWateringSchedule,
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        onPressed: _addSchedule,
                        child: Text(context.l10n.addScheduleTitle),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final schedule = _schedules[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ScheduleCard(
                        schedule: schedule,
                        onDelete: () => _deleteSchedule(schedule),
                      ),
                    );
                  }, childCount: _schedules.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final PumpSchedule schedule;
  final VoidCallback onDelete;

  const _ScheduleCard({required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    schedule.isEnabled
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    color: schedule.isEnabled
                        ? AppColors.forestGreen
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(schedule.startTime),
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.sprayDurationSummary(
              (schedule.durationSeconds).toString(),
            ),
            style: TextStyle(color: AppColors.primaryText, fontSize: 15),
          ),
          if (schedule.intervalMinutes != null) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.sprayIntervalSummary(
                (schedule.intervalMinutes).toString(),
              ),
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            context.l10n.scheduleDaysSummary(
              (_formatDays(context, schedule.weekdayMask)).toString(),
            ),
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return timeString;
  }

  String _formatDays(BuildContext context, int mask) {
    final days = context.localizedWeekdays;
    final selected = [
      for (var day = 0; day < days.length; day++)
        if ((mask & (1 << day)) != 0) days[day],
    ];
    return selected.isEmpty ? context.l10n.noDaysSelected : selected.join(', ');
  }
}

class AddScheduleDialog extends StatefulWidget {
  final Device device;

  const AddScheduleDialog({super.key, required this.device});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final ApiService _apiService = ApiService();
  final _mistLengthController = TextEditingController(text: '30');
  final _intervalController = TextEditingController(text: '30');

  SchedulePreset _selectedPreset = SchedulePreset.custom;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 12));
  final List<int> _selectedDays = [1, 2, 3, 4, 5];

  bool _isSaving = false;
  String Function()? _errorMessage;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _mistLengthController.addListener(_onChanged);
    _intervalController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _mistLengthController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _hasUnsavedChanges = true);
  }

  void _applyPreset(SchedulePreset preset) {
    setState(() {
      _selectedPreset = preset;
      _mistLengthController.text = preset.defaultMistLength.toString();
      _intervalController.text = preset.defaultInterval.toString();
      _hasUnsavedChanges = true;
    });
  }

  String? _validateMistLength(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.sprayDurationRequired;
    }
    final length = int.tryParse(value);
    if (length == null || length < 1 || length > 120) {
      return context.l10n.sprayDurationRange;
    }
    return null;
  }

  String? _validateInterval(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.scheduleIntervalRequired;
    }
    final interval = int.tryParse(value);
    if (interval == null || interval < 1 || interval > 60) {
      return context.l10n.scheduleIntervalRange;
    }
    final mistLength = int.tryParse(_mistLengthController.text);
    if (mistLength != null && mistLength >= interval * 60) {
      return context.l10n.sprayDurationLessThanInterval;
    }
    return null;
  }

  String? _validateTimeWindow() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes && endMinutes < startMinutes + 60) {
      return context.l10n.scheduleEndAfterStart;
    }
    return null;
  }

  String _getLiveSummary() {
    final mistLength = _mistLengthController.text;
    final interval = _intervalController.text;
    final days = _selectedDays
        .map((d) => context.localizedWeekdays[d])
        .join(', ');

    return context.l10n.schedulePreview(
      (mistLength).toString(),
      (interval).toString(),
      (_startTime.format(context)).toString(),
      (_endTime.format(context)).toString(),
      (days).toString(),
    );
  }

  Future<void> _save() async {
    final mistLengthError = _validateMistLength(_mistLengthController.text);
    final intervalError = _validateInterval(_intervalController.text);
    final timeWindowError = _validateTimeWindow();

    if (mistLengthError != null ||
        intervalError != null ||
        timeWindowError != null) {
      setState(() {
        _errorMessage = () =>
            _validateMistLength(_mistLengthController.text) ??
            _validateInterval(_intervalController.text) ??
            _validateTimeWindow() ??
            '';
      });
      return;
    }

    if (_selectedDays.isEmpty) {
      setState(() => _errorMessage = () => context.l10n.selectScheduleDay);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      String wallClock(DateTime time) =>
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
      final startTimeStr = wallClock(_startTime);
      final endTimeStr = wallClock(_endTime);

      await _apiService.createPumpSchedule(
        widget.device.id,
        startTimeStr,
        int.parse(_mistLengthController.text),
        _selectedDays,
        intervalMinutes: int.parse(_intervalController.text),
        endTime: endTimeStr,
      );

      if (mounted) {
        HapticFeedback.lightImpact();
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: Text(context.l10n.savedTitle),
            content: Text(context.l10n.savedToDevice),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = () =>
              context.l10n.saveFailed(localizedApiError(e, context.l10n));
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.l10n.unsavedTitle),
        content: Text(context.l10n.unsavedChangesConfirmation),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.keepEditing),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.discardChanges),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_hasUnsavedChanges) return;
        final navigator = Navigator.of(context);
        if (await _onWillPop()) {
          navigator.pop();
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(context.l10n.addScheduleTitle),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const CupertinoActivityIndicator(radius: 12)
                : Text(context.l10n.save),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                sliver: SliverList.list(
                  children: [
                    Text(context.l10n.deviceScheduleTimezoneHint),
                    const SizedBox(height: 12),
                    // Preset chips
                    Text(
                      context.l10n.schedulePreset,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SchedulePreset.values.map((preset) {
                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          color: _selectedPreset == preset
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.secondarySystemBackground
                                    .resolveFrom(context),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () => _applyPreset(preset),
                          child: Text(
                            preset.localizedLabel(context),
                            style: TextStyle(
                              color: _selectedPreset == preset
                                  ? CupertinoColors.white
                                  : AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Mist length
                    _ScheduleField(
                      label: context.l10n.sprayDurationSeconds,
                      controller: _mistLengthController,
                      keyboardType: TextInputType.number,
                      placeholder: '1-120',
                      errorText: _validateMistLength(
                        _mistLengthController.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interval
                    _ScheduleField(
                      label: context.l10n.scheduleIntervalMinutes,
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      placeholder: '1-60',
                      errorText: _validateInterval(_intervalController.text),
                    ),
                    const SizedBox(height: 16),

                    // Active hours
                    Text(
                      context.l10n.scheduleTimeWindow,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeButton(
                            label: context.l10n.scheduleStart,
                            time: _startTime,
                            onTap: () => _selectTime(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeButton(
                            label: context.l10n.scheduleEnd,
                            time: _endTime,
                            onTap: () => _selectTime(false),
                          ),
                        ),
                      ],
                    ),
                    if (_validateTimeWindow() != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _validateTimeWindow()!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Days of week
                    Text(
                      context.l10n.scheduleRepeatDays,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final dayNames = context.localizedWeekdays;
                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          color: _selectedDays.contains(index)
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.secondarySystemBackground
                                    .resolveFrom(context),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            setState(() {
                              if (_selectedDays.contains(index)) {
                                _selectedDays.remove(index);
                              } else {
                                _selectedDays.add(index);
                              }
                              _hasUnsavedChanges = true;
                            });
                          },
                          child: Text(
                            dayNames[index],
                            style: TextStyle(
                              color: _selectedDays.contains(index)
                                  ? CupertinoColors.white
                                  : AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Live summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.resolveFrom(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.info_circle,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getLiveSummary(),
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              size: 16,
                              color: CupertinoColors.systemRed,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!(),
                                style: const TextStyle(
                                  color: CupertinoColors.systemRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _save,
                              child: Text(context.l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: isStart ? _startTime : _endTime,
            onDateTimeChanged: (DateTime newTime) {
              setState(() {
                if (isStart) {
                  _startTime = newTime;
                } else {
                  _endTime = newTime;
                }
                _hasUnsavedChanges = true;
              });
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String placeholder;
  final String? errorText;

  const _ScheduleField({
    required this.label,
    required this.controller,
    this.keyboardType,
    required this.placeholder,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      CupertinoTextField(
        controller: controller,
        keyboardType: keyboardType,
        placeholder: placeholder,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: errorText != null
                ? CupertinoColors.systemRed.resolveFrom(context)
                : CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      if (errorText != null) ...[
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            errorText!,
            style: const TextStyle(
              color: CupertinoColors.systemRed,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ],
  );
}

class _TimeButton extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

extension on DateTime {
  String format(BuildContext context) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
