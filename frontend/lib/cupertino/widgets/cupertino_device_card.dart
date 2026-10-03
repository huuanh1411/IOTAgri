import 'package:flutter/cupertino.dart';
import '../../models/device_overview.dart';

class CupertinoDeviceCard extends StatelessWidget {
  final DeviceOverview device;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CupertinoDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline;
    final latestReading = device.latestReading;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CupertinoColors.systemBackground.resolveFrom(context),
                        CupertinoColors.systemGrey6.resolveFrom(context),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          isOnline ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                          color: isOnline 
                              ? CupertinoColors.systemGreen 
                              : CupertinoColors.systemRed,
                          size: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? CupertinoColors.systemGreen.withValues(alpha: 0.15)
                                : CupertinoColors.systemRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isOnline 
                                  ? CupertinoColors.systemGreen 
                                  : CupertinoColors.systemRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Device name
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Sensor values
                    if (latestReading != null) ...[
                      _buildSensorRow(
                        context,
                        'Nhiệt độ',
                        '${latestReading.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                        CupertinoColors.systemOrange,
                        CupertinoIcons.thermometer,
                      ),
                      const SizedBox(height: 8),
                      _buildSensorRow(
                        context,
                        'Độ ẩm',
                        '${latestReading.humidity?.toStringAsFixed(1) ?? 'N/A'}%',
                        CupertinoColors.systemBlue,
                        CupertinoIcons.drop,
                      ),
                    ] else
                      const Text(
                        'Chưa có dữ liệu',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(
    BuildContext context,
    String label,
    String value,
    CupertinoDynamicColor color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color.resolveFrom(context),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}