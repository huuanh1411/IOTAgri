import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'cupertino/auth/cupertino_login_screen.dart';
import 'cupertino/dashboard/cupertino_dashboard_screen.dart';
import 'cupertino/admin/cupertino_admin_dashboard_screen.dart';
import 'cupertino/devices/cupertino_device_detail_screen.dart';
import 'cupertino/notifications/notification_banner_host.dart';
import 'cupertino/responsive/responsive_layout.dart';
import 'cupertino/theme/cupertino_theme.dart' as theme;
import 'cupertino/widgets/global_offline_banner.dart';
import 'providers/alert_center_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'services/connectivity_service.dart';
import 'services/notification_service.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AerogreenApp());
}

class AerogreenApp extends StatelessWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        Provider<NotificationService>(
          create: (_) => FakeNotificationService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => AlertCenterProvider(
            notificationService: context.read<NotificationService>(),
          ),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          final activeTheme = settings.themeMode == AppThemeMode.dark
              ? theme.AerogreenCupertinoTheme.darkTheme
              : theme.AerogreenCupertinoTheme.lightTheme;

          return CupertinoApp(
            navigatorKey: rootNavigatorKey,
            title: 'Aerogreen',
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            theme: activeTheme,
            builder: (appContext, child) => GlobalOfflineBanner(
              child: NotificationBannerHost(
                service: context.read<NotificationService>(),
                onOpen: (message) {
                  final device = message.device;
                  if (device == null) return;
                  rootNavigatorKey.currentState?.push<void>(
                    CupertinoPageRoute(
                      builder: (_) => CupertinoDeviceDetailScreen(
                        device: device,
                        initialSensor: message.sensor,
                      ),
                    ),
                  );
                },
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 1. Chưa khởi tạo xong → hiện loading
        if (!authProvider.isInitialized) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
          );
        }

        // 2. Đã đăng nhập → kiểm tra role
        if (authProvider.isAuthenticated) {
          final isAdmin = authProvider.user?.isAdmin ?? false;

          if (isAdmin) {
            // → Màn hình Admin
            return const ResponsiveLayout(
              mobile: CupertinoAdminDashboardScreen(),
              tablet: CupertinoAdminDashboardScreen(),
              desktop: CupertinoAdminDashboardScreen(),
            );
          }

          // → Màn hình User
          return const ResponsiveLayout(
            mobile: CupertinoDashboardScreen(),
            tablet: CupertinoDashboardScreen(),
            desktop: CupertinoDashboardScreen(),
          );
        }

        // 3. Chưa đăng nhập → màn hình login
        return const CupertinoLoginScreen();
      },
    );
  }
}
