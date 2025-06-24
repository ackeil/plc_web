// lib/src/config/routes/app_router.dart
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/recover_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/equipment/presentation/pages/equipment_list_page.dart';
import '../../features/users/presentation/pages/users_list_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      
      case '/recover-password':
        return MaterialPageRoute(
          builder: (_) => const RecoverPasswordPage(),
        );
      
      // case '/dashboard':
      //   return MaterialPageRoute(
      //     builder: (_) => const DashboardPage(),
      //   );
      
      // case '/equipment':
      //   return MaterialPageRoute(
      //     builder: (_) => const EquipmentListPage(),
      //   );
      
      // case '/users':
      //   return MaterialPageRoute(
      //     builder: (_) => const UsersListPage(),
      //   );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Erro'),
            ),
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}