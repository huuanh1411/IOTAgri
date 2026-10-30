import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Dialog shown when session is about to expire
class SessionTimeoutDialog extends StatelessWidget {
  final Duration? timeUntilExpiry;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const SessionTimeoutDialog({
    super.key,
    required this.timeUntilExpiry,
    required this.onRefresh,
    required this.onLogout,
  });

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút';
    }
    return '${duration.inSeconds} giây';
  }

  @override
  Widget build(BuildContext context) {
    final remainingText = timeUntilExpiry != null
        ? 'Phiên làm việc của bạn sẽ hết hạn sau ${_formatDuration(timeUntilExpiry!)}.'
        : 'Phiên làm việc của bạn sắp hết hạn.';

    return CupertinoAlertDialog(
      title: const Text('Phiên làm việc sắp hết hạn'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text(remainingText),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Đăng xuất'),
          onPressed: () {
            Navigator.of(context).pop();
            onLogout();
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Gia hạn'),
          onPressed: () {
            Navigator.of(context).pop();
            onRefresh();
          },
        ),
      ],
    );
  }
}

/// Material Design version of the session timeout dialog
class SessionTimeoutDialogMaterial extends StatelessWidget {
  final Duration? timeUntilExpiry;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const SessionTimeoutDialogMaterial({
    super.key,
    required this.timeUntilExpiry,
    required this.onRefresh,
    required this.onLogout,
  });

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút';
    }
    return '${duration.inSeconds} giây';
  }

  @override
  Widget build(BuildContext context) {
    final remainingText = timeUntilExpiry != null
        ? 'Phiên làm việc của bạn sẽ hết hạn sau ${_formatDuration(timeUntilExpiry!)}.'
        : 'Phiên làm việc của bạn sắp hết hạn.';

    return AlertDialog(
      title: const Text('Phiên làm việc sắp hết hạn'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text(remainingText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLogout();
          },
          child: const Text('Đăng xuất'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRefresh();
          },
          child: const Text('Gia hạn'),
        ),
      ],
    );
  }
}
