// lib/src/config/app_router.dart

import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/equipment/equipment_detail_screen.dart';
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
    '/equipment/form': (context) => const EquipmentFormScreen(),
    '/users': (context) => const UsersListScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/reports': (context) => const ReportsScreen(),
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
        
      case '/equipment/form':
        final equipmentId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => EquipmentFormScreen(equipmentId: equipmentId),
          settings: settings,
        );
        
      default:
        return null;
    }
  }
  
  /// Verifica permissões de acesso às rotas
  static Route<dynamic>? checkAccess(Route<dynamic>? route) {
    if (route == null) return null;
    
    final user = _authService.currentUser;
    final routeName = route.settings.name;
    
    // Rotas que requerem autenticação
    final protectedRoutes = [
      '/home',
      '/equipment',
      '/users',
      '/settings',
      '/reports',
    ];
    
    // Rotas administrativas (apenas admin e gerente)
    final adminRoutes = [
      '/users',
      '/equipment/form',
    ];
    
    // Verifica se precisa autenticação
    if (protectedRoutes.any((r) => routeName?.startsWith(r) == true)) {
      if (user == null) {
        return _redirectRoute('/login');
      }
    }
    
    // Verifica permissões administrativas
    if (adminRoutes.any((r) => routeName?.startsWith(r) == true)) {
      if (user?.role == UserRole.operator) {
        return _errorRoute('Acesso negado');
      }
    }
    
    return route;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Rota de redirecionamento
  static Route<dynamic> _redirectRoute(String routeName) {
    return MaterialPageRoute(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(routeName);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// Telas placeholder temporárias (serão substituídas pelas implementações reais)

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Equipamentos')),
      body: const Center(child: Text('Lista completa de equipamentos')),
    );
  }
}

class EquipmentFormScreen extends StatelessWidget {
  final String? equipmentId;
  
  const EquipmentFormScreen({Key? key, this.equipmentId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isEditing = equipmentId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Equipamento' : 'Novo Equipamento'),
      ),
      body: Center(
        child: Text(
          isEditing 
              ? 'Formulário de edição: $equipmentId' 
              : 'Formulário de cadastro',
        ),
      ),
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
      body: const Center(child: Text('Configurações do sistema')),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: const Center(child: Text('Relatórios e análises')),
    );
  }
}