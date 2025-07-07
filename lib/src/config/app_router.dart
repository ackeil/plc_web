// lib/config/app_router.dart

import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Gerenciador de rotas do AFT-PLC-WEB
class AppRouter {
  static final AuthService _authService = AuthService();
  
  /// Define todas as rotas do aplicativo
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/equipment': (context) => const EquipmentListScreen(),
    '/users': (context) => const UsersListScreen(),
    '/settings': (context) => const SettingsScreen(),
  };
  
  /// Gera rotas com parâmetros
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/equipment/detail':
        final equipmentId = settings.arguments as String?;
        if (equipmentId == null) {
          return _errorRoute('ID do equipamento não fornecido');
        }
        return MaterialPageRoute(
          builder: (context) => EquipmentDetailScreen(equipmentId: equipmentId),
          settings: settings,
        );
        
      default:
        return null;
    }
  }
  
  /// Rota de erro
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}

// Telas placeholder temporárias
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bem-vindo ao AFT-PLC-WEB!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipamentos')),
      body: const Center(child: Text('Lista de equipamentos')),
    );
  }
}

class EquipmentDetailScreen extends StatelessWidget {
  final String equipmentId;
  const EquipmentDetailScreen({Key? key, required this.equipmentId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Equipamento')),
      body: Center(child: Text('Equipamento: $equipmentId')),
    );
  }
}

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: const Center(child: Text('Lista de usuários')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: const Center(child: Text('Configurações')),
    );
  }
}