import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'cupertino/auth/cupertino_login_screen.dart';
import 'cupertino/dashboard/cupertino_dashboard_screen.dart';
import 'cupertino/admin/cupertino_admin_dashboard_screen.dart';
import 'cupertino/responsive/responsive_layout.dart';
import 'cupertino/theme/cupertino_theme.dart' as theme;
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AerogreenApp());
}

class AerogreenApp extends StatelessWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: CupertinoApp(
        title: 'Aerogreen',
        debugShowCheckedModeBanner: false,
        theme: theme.AerogreenCupertinoTheme.lightTheme,
        home: const AuthWrapper(),
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
