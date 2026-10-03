import 'package:flutter/cupertino.dart';

import '../../models/device_overview.dart';
import '../theme/cupertino_theme.dart';

enum FarmHealthLevel { noDevices, healthy, attention, critical }

class FarmHealthIssue {
  final DeviceOverview device;
  final String message;
  final IconData icon;
  final bool isCritical;

  const FarmHealthIssue({
    required this.device,
    required this.message,
    required this.icon,
    this.isCritical = false,
  });
}

class FarmHealthSummary {
  final FarmHealthLevel level;
  final List<FarmHealthIssue> issues;

  const FarmHealthSummary(this.level, this.issues);

  factory FarmHealthSummary.fromDevices(List<DeviceOverview> devices) {
    if (devices.isEmpty) {
      return const FarmHealthSummary(FarmHealthLevel.noDevices, []);
    }

    final issues = <FarmHealthIssue>[];
    for (final device in devices) {
      if (!device.isOnline) {
        issues.add(
          FarmHealthIssue(
            device: device,
            message: 'Thiết bị mất kết nối.',
            icon: CupertinoIcons.wifi_slash,
          ),
        );
      }

      for (final alert in device.alerts) {
        final isLowWater = alert.type.toUpperCase() == 'LOW_WATER_LEVEL';
        final isHighTemperature =
            alert.type.toUpperCase() == 'HIGH_TEMPERATURE';
        issues.add(
          FarmHealthIssue(
            device: device,
            message: isLowWater
                ? 'Mực nước thấp: ${alert.measuredValue.toStringAsFixed(0)}%.'
                : isHighTemperature
                ? 'Nhiệt độ cao: ${alert.measuredValue.toStringAsFixed(1)}°C.'
                : 'Cần kiểm tra cảm biến.',
            icon: isLowWater
                ? CupertinoIcons.drop_triangle
                : CupertinoIcons.thermometer,
            isCritical: isLowWater,
          ),
        );
      }
    }

    final level = issues.any((issue) => issue.isCritical)
        ? FarmHealthLevel.critical
        : issues.isNotEmpty
        ? FarmHealthLevel.attention
        : FarmHealthLevel.healthy;
    return FarmHealthSummary(level, List.unmodifiable(issues));
  }

  String get title => switch (level) {
    FarmHealthLevel.noDevices => 'Chào mừng đến Aerogreen',
    FarmHealthLevel.healthy => 'Trang trại đang ổn định',
    FarmHealthLevel.attention => 'Cần chú ý',
    FarmHealthLevel.critical => 'Cần xử lý ngay',
  };

  String get message => switch (level) {
    FarmHealthLevel.noDevices =>
      'Thêm thiết bị đầu tiên để theo dõi trang trại.',
    FarmHealthLevel.healthy => 'Tất cả thiết bị đang hoạt động bình thường.',
    FarmHealthLevel.attention => '${issues.length} vấn đề cần kiểm tra.',
    FarmHealthLevel.critical => 'Phát hiện tình trạng ảnh hưởng đến vận hành.',
  };

  Color get tint => switch (level) {
    FarmHealthLevel.noDevices => CupertinoColors.systemGrey6,
    FarmHealthLevel.healthy =>
      AerogreenCupertinoTheme.aerogreenPrimary.withValues(alpha: 0.12),
    FarmHealthLevel.attention => CupertinoColors.systemOrange.withValues(
      alpha: 0.14,
    ),
    FarmHealthLevel.critical => CupertinoColors.systemRed.withValues(
      alpha: 0.12,
    ),
  };

  Color get accent => switch (level) {
    FarmHealthLevel.noDevices => CupertinoColors.systemGrey,
    FarmHealthLevel.healthy => AerogreenCupertinoTheme.aerogreenPrimary,
    FarmHealthLevel.attention => CupertinoColors.systemOrange,
    FarmHealthLevel.critical => CupertinoColors.systemRed,
  };

  IconData get icon => switch (level) {
    FarmHealthLevel.noDevices => CupertinoIcons.leaf_arrow_circlepath,
    FarmHealthLevel.healthy => CupertinoIcons.checkmark_circle_fill,
    FarmHealthLevel.attention => CupertinoIcons.exclamationmark_triangle_fill,
    FarmHealthLevel.critical => CupertinoIcons.exclamationmark_octagon_fill,
  };
}

class FarmHealthCard extends StatelessWidget {
  final FarmHealthSummary summary;
  final VoidCallback? onAddDevice;

  const FarmHealthCard({super.key, required this.summary, this.onAddDevice});

  @override
  Widget build(BuildContext context) {
    final isEmpty = summary.level == FarmHealthLevel.noDevices;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: summary.tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(summary.icon, color: summary.accent, size: 25),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  summary.message,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (isEmpty && onAddDevice != null) ...[
                  const SizedBox(height: 14),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: onAddDevice,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, size: 16),
                        SizedBox(width: 7),
                        Text('Thêm thiết bị'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
