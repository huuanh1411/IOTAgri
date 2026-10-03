// ============================================================
// cupertino_system_config_screen.dart
// Màn hình Cấu hình hệ thống.
// Chức năng:
//   - Alert Thresholds (mặc định cho mọi device)
//   - Notification settings (push/email/sms)
//   - Maintenance mode
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_theme.dart';

class CupertinoSystemConfigScreen extends StatefulWidget {
  const CupertinoSystemConfigScreen({super.key});

  @override
  State<CupertinoSystemConfigScreen> createState() =>
      _CupertinoSystemConfigScreenState();
}

class _CupertinoSystemConfigScreenState
    extends State<CupertinoSystemConfigScreen> {
  // Alert thresholds
  double _maxTemp = 35.0;
  double _minTemp = 15.0;
  double _minHumidity = 40.0;
  double _minWaterLevel = 20.0;

  // Notification settings
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  // Maintenance mode
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Cấu hình'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: _saveConfig,
            child: const Text(
              'Lưu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader(context, 'Ngưỡng cảnh báo (mặc định)'),
              const SizedBox(height: 10),
              _buildSlider(
                context,
                icon: CupertinoIcons.thermometer,
                color: CupertinoColors.systemRed,
                label: 'Nhiệt độ tối đa',
                value: _maxTemp,
                min: 20,
                max: 50,
                unit: '°C',
                onChanged: (v) => setState(() => _maxTemp = v),
              ),
              const SizedBox(height: 10),
              _buildSlider(
                context,
                icon: CupertinoIcons.thermometer,
                color: CupertinoColors.systemBlue,
                label: 'Nhiệt độ tối thiểu',
                value: _minTemp,
                min: 0,
                max: 25,
                unit: '°C',
                onChanged: (v) => setState(() => _minTemp = v),
              ),
              const SizedBox(height: 10),
              _buildSlider(
                context,
                icon: CupertinoIcons.drop_fill,
                color: CupertinoColors.systemTeal,
                label: 'Độ ẩm tối thiểu',
                value: _minHumidity,
                min: 20,
                max: 80,
                unit: '%',
                onChanged: (v) => setState(() => _minHumidity = v),
              ),
              const SizedBox(height: 10),
              _buildSlider(
                context,
                icon: CupertinoIcons.drop_triangle,
                color: AerogreenCupertinoTheme.aerogreenPrimary,
                label: 'Mực nước tối thiểu',
                value: _minWaterLevel,
                min: 5,
                max: 50,
                unit: '%',
                onChanged: (v) => setState(() => _minWaterLevel = v),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Thông báo'),
              const SizedBox(height: 10),
              _buildToggle(
                context,
                icon: CupertinoIcons.bell_fill,
                color: CupertinoColors.systemBlue,
                label: 'Push notifications',
                subtitle: 'Thông báo đẩy trên thiết bị di động',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              const SizedBox(height: 10),
              _buildToggle(
                context,
                icon: CupertinoIcons.mail_solid,
                color: CupertinoColors.systemOrange,
                label: 'Email notifications',
                subtitle: 'Gửi email khi có cảnh báo quan trọng',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
              const SizedBox(height: 10),
              _buildToggle(
                context,
                icon: CupertinoIcons.phone_fill,
                color: CupertinoColors.systemGreen,
                label: 'SMS notifications',
                subtitle: 'Gửi SMS khi có sự cố nghiêm trọng',
                value: _smsEnabled,
                onChanged: (v) => setState(() => _smsEnabled = v),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Bảo trì'),
              const SizedBox(height: 10),
              _buildToggle(
                context,
                icon: CupertinoIcons.wrench_fill,
                color: CupertinoColors.systemRed,
                label: 'Chế độ bảo trì',
                subtitle: 'Tạm dừng dịch vụ để bảo trì hệ thống',
                value: _maintenanceMode,
                onChanged: (v) => setState(() => _maintenanceMode = v),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSlider(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String label,
        required double value,
        required double min,
        required double max,
        required String unit,
        required ValueChanged<double> onChanged,
      }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}$unit',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String label,
        required String subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AerogreenCupertinoTheme.aerogreenPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _saveConfig() {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Đã lưu'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Cấu hình hệ thống đã được cập nhật.'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}