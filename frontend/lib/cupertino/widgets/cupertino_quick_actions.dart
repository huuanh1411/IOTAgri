import 'package:flutter/cupertino.dart';

class CupertinoQuickActions extends StatelessWidget {
  final VoidCallback? onAddDevice;
  final VoidCallback? onRefresh;
  final VoidCallback? onSettings;

  const CupertinoQuickActions({
    super.key,
    this.onAddDevice,
    this.onRefresh,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            CupertinoIcons.add_circled,
            'Thêm',
            onAddDevice,
          ),
          _buildActionButton(
            context,
            CupertinoIcons.refresh,
            'Làm mới',
            onRefresh,
          ),
          _buildActionButton(
            context,
            CupertinoIcons.settings,
            'Cài đặt',
            onSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onPressed,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.systemBlue.resolveFrom(context),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}