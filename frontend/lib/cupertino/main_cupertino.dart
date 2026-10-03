import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard/cupertino_dashboard_screen.dart';
import 'theme/cupertino_theme.dart' as theme;
import 'responsive/responsive_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const AerogreenApp());
}

class AerogreenApp extends StatelessWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: CupertinoApp(
        title: 'Aerogreen - Hệ Thống Nông Thông Minh',
        debugShowCheckedModeBanner: false,
        theme: theme.AerogreenCupertinoTheme.lightTheme,
        localizationsDelegates: const [
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en', 'US'),
        ],
        locale: const Locale('vi', 'VN'),
        home: const CupertinoAuthWrapper(),
      ),
    );
  }
}

class CupertinoAuthWrapper extends StatelessWidget {
  const CupertinoAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const ResponsiveLayout(
            mobile: CupertinoDashboardScreen(),
            // TODO: Add tablet and desktop layouts
          );
        } else {
          // TODO: Add Cupertino login screen
          return const CupertinoLoginScreen();
        }
      },
    );
  }
}

class CupertinoLoginScreen extends StatelessWidget {
  const CupertinoLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Đăng nhập'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.checkmark_circle,
                size: 80,
                color: theme.AerogreenCupertinoTheme.aerogreenPrimary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Aerogreen',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hệ Thống Nông Thông Minh',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 48),
              const CupertinoActivityIndicator(radius: 20),
            ],
          ),
        ),
      ),
    );
  }
}