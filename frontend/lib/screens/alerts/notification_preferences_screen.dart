import '../../utils/l10n.dart';
import 'package:flutter/cupertino.dart';

import '../../models/notification_preferences.dart';
import '../../services/notification_preferences_store.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key, this.store});

  final NotificationPreferencesStore? store;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late final NotificationPreferencesStore _store;
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? NotificationPreferencesStore();
    _load();
  }

  Future<void> _load() async {
    final value = await _store.load();
    if (mounted) {
      setState(() {
        _preferences = value;
        _loading = false;
      });
    }
  }

  Future<void> _save(NotificationPreferences value) async {
    setState(() => _preferences = value);
    await _store.save(value);
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: Text(context.l10n.notificationPreferencesTitle),
    ),
    child: SafeArea(
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                _section([
                  _toggleRow(
                    context.l10n.notifications,
                    context.l10n.notificationsToggleHint,
                    _preferences.enabled,
                    (value) => _save(_preferences.copyWith(enabled: value)),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(
                  context.l10n.severityHeading,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _section([
                  _toggleRow(
                    context.l10n.criticalSeverity,
                    context.l10n.criticalNotificationsHint,
                    _preferences.critical,
                    (value) => _save(_preferences.copyWith(critical: value)),
                  ),
                  _divider(),
                  _toggleRow(
                    context.l10n.alerts,
                    context.l10n.warningNotificationsHint,
                    _preferences.warning,
                    (value) => _save(_preferences.copyWith(warning: value)),
                  ),
                  _divider(),
                  _toggleRow(
                    context.l10n.infoSeverity,
                    context.l10n.infoNotificationsHint,
                    _preferences.info,
                    (value) => _save(_preferences.copyWith(info: value)),
                  ),
                ]),
                const SizedBox(height: 18),
                _section([
                  _toggleRow(
                    context.l10n.quietHoursTitle,
                    _quietLabel,
                    _preferences.quietHoursEnabled,
                    (value) =>
                        _save(_preferences.copyWith(quietHoursEnabled: value)),
                  ),
                  if (_preferences.quietHoursEnabled) ...[
                    _divider(),
                    _timeRow(
                      context.l10n.scheduleStart,
                      _preferences.quietStartMinutes,
                      (value) => _save(
                        _preferences.copyWith(quietStartMinutes: value),
                      ),
                    ),
                    _divider(),
                    _timeRow(
                      context.l10n.scheduleEnd,
                      _preferences.quietEndMinutes,
                      (value) =>
                          _save(_preferences.copyWith(quietEndMinutes: value)),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),
                Text(
                  context.l10n.criticalIgnoresQuietHours,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    ),
  );

  String get _quietLabel =>
      '${_formatMinutes(_preferences.quietStartMinutes)} – ${_formatMinutes(_preferences.quietEndMinutes)}';

  Widget _section(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: children),
  );

  Widget _toggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    ),
  );

  Widget _timeRow(String title, int value, ValueChanged<int> onChanged) =>
      CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        onPressed: () => _pickTime(value, onChanged),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Text(_formatMinutes(value)),
            const SizedBox(width: 6),
            const Icon(CupertinoIcons.chevron_right, size: 15),
          ],
        ),
      );

  Future<void> _pickTime(int initial, ValueChanged<int> onChanged) async {
    var date = DateTime(2020, 1, 1, initial ~/ 60, initial % 60);
    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (popupContext) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () => Navigator.of(popupContext).pop(date),
                  child: const Text('Xong'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: date,
                  onDateTimeChanged: (value) => date = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) onChanged(result.hour * 60 + result.minute);
  }

  Widget _divider() => Container(
    height: 0.5,
    margin: const EdgeInsets.only(left: 16),
    color: CupertinoColors.separator.resolveFrom(context),
  );

  String _formatMinutes(int value) =>
      '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';
}
