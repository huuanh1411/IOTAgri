import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'session_timeout_dialog.dart';

/// Listener widget that shows session timeout dialog when triggered
class SessionTimeoutListener extends StatefulWidget {
  final Widget child;

  const SessionTimeoutListener({
    super.key,
    required this.child,
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    // Listen for session warning callback
    authProvider.onSessionWarningCallback = _onSessionWarning;
  }

  @override
  void dispose() {
    final authProvider = context.read<AuthProvider>();
    authProvider.onSessionWarningCallback = null;
    super.dispose();
  }

  void _onSessionWarning() {
    if (_isDialogShown || !mounted) return;
    
    _isDialogShown = true;
    final authProvider = context.read<AuthProvider>();
    final sessionManager = authProvider.sessionTimeoutManager;
    final timeUntilExpiry = sessionManager.getTimeUntilExpiry();

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SessionTimeoutDialog(
        timeUntilExpiry: timeUntilExpiry,
        onRefresh: () async {
          Navigator.of(dialogContext).pop();
          _isDialogShown = false;
          
          // Trigger a refresh by making an authenticated request
          try {
            await authProvider.loadProfile();
            // If successful, the session timeout manager will update
            // and won't show the warning again until next time
          } catch (e) {
            // If refresh fails, user will be logged out
            await authProvider.logout();
          }
        },
        onLogout: () async {
          Navigator.of(dialogContext).pop();
          _isDialogShown = false;
          await authProvider.logout();
        },
      ),
    ).then((_) {
      _isDialogShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
