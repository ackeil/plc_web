// lib/services/auth_service.dart

import 'dart:async';
import '../models/user_model.dart';

/// Serviço de autenticação para demonstração (sem Firebase)
class AuthService {
  // Usuário atualmente logado
  UserModel? _currentUser;
  
  // Stream controller para mudanças de autenticação
  final _authStateController = StreamController<UserModel?>.broadcast();
  
  // Credenciais do usuário demo
  static const String demoEmail = 'teste@ucs.br';
  static const String demoPassword = 'Teste123';
  
  // Usuário administrador demo
  final UserModel _demoAdmin = UserModel(
    id: 'demo-admin-001',
    email: demoEmail,
    name: 'Administrador Demo',
    phoneNumber: '(54) 99999-9999',
    role: UserRole.administrator,
    createdAt: DateTime(2024, 1, 1),
    lastLogin: DateTime.now(),
    isActive: true,
    companyName: 'Alfatronic Demo',
    companyId: 'alfatronic-demo',
    isManufacturer: true,
    emailVerified: true,
    notificationsEnabled: true,
  );
  
  // Lista de usuários demo
  final List<UserModel> _demoUsers = [
    UserModel(
      id: 'demo-manager-001',
      email: 'gerente@demo.com',
      name: 'João Silva',
      phoneNumber: '(54) 98888-8888',
      role: UserRole.manager,
      createdAt: DateTime(2024, 2, 1),
      isActive: true,
      companyName: 'Empresa ABC',
      companyId: 'empresa-abc',
      isManufacturer: true,
      emailVerified: true,
    ),
    UserModel(
      id: 'demo-operator-001',
      email: 'operador@demo.com',
      name: 'Carlos Oliveira',
      phoneNumber: '(54) 97777-7777',
      role: UserRole.operator,
      createdAt: DateTime(2024, 3, 1),
      isActive: true,
      companyName: 'Empresa ABC',
      companyId: 'empresa-abc',
      managerId: 'demo-manager-001',
      authorizedEquipmentIds: ['equip-001', 'equip-002'],
      emailVerified: true,
    ),
  ];
  
  // Getters
  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  bool get isLoggedIn => _currentUser != null;
  
  /// Faz login com email e senha
  Future<UserModel> signIn({
    required String email, 
    required String password,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Verifica credenciais do admin demo
    if (email.toLowerCase() == demoEmail && password == demoPassword) {
      _currentUser = _demoAdmin;
      _authStateController.add(_currentUser);
      return _demoAdmin;
    }
    
    // Verifica outros usuários demo
    if (email == 'gerente@demo.com' && password == '123456') {
      _currentUser = _demoUsers[0];
      _authStateController.add(_currentUser);
      return _demoUsers[0];
    }
    
    if (email == 'operador@demo.com' && password == '123456') {
      _currentUser = _demoUsers[1];
      _authStateController.add(_currentUser);
      return _demoUsers[1];
    }
    
    // Credenciais inválidas
    throw AuthException(
      'Email ou senha incorretos',
      'invalid-credentials',
    );
  }
  
  /// Faz logout
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.add(null);
  }
  
  /// Retorna o usuário atual
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
  
  /// Retorna lista de todos os usuários
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser == null) return [];
    
    // Admin vê todos
    if (_currentUser!.role == UserRole.administrator) {
      return [_demoAdmin, ..._demoUsers];
    }
    
    // Gerente vê apenas da sua empresa
    if (_currentUser!.role == UserRole.manager) {
      return _demoUsers.where((user) => 
        user.companyId == _currentUser!.companyId
      ).toList();
    }
    
    // Operador vê apenas a si mesmo
    return [_currentUser!];
  }
  
  /// Cria um novo usuário (apenas simula)
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String? companyId,
    String? managerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Validações básicas
    if (_currentUser == null) {
      throw AuthException('Não autorizado', 'unauthorized');
    }
    
    if (_currentUser!.role == UserRole.operator) {
      throw AuthException(
        'Operadores não podem criar usuários',
        'insufficient-permissions',
      );
    }
    
    if (_currentUser!.role == UserRole.manager && role != UserRole.operator) {
      throw AuthException(
        'Gerentes só podem criar operadores',
        'insufficient-permissions',
      );
    }
    
    // Cria novo usuário
    final newUser = UserModel(
      id: 'demo-temp-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
      isActive: true,
      companyId: companyId ?? _currentUser!.companyId,
      companyName: _currentUser!.companyName,
      managerId: role == UserRole.operator ? _currentUser!.id : null,
      emailVerified: true,
    );
    
    _demoUsers.add(newUser);
    return newUser;
  }
  
  /// Atualiza um usuário
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _demoUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      // Aqui você atualizaria o usuário
      print('Usuário atualizado: $userId');
    }
  }
  
  /// Deleta um usuário
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _demoUsers.removeWhere((u) => u.id == userId);
  }
  
  /// Limpa todos os dados (útil para testes)
  void dispose() {
    _authStateController.close();
  }
}

/// Exceção customizada para erros de autenticação
class AuthException implements Exception {
  final String message;
  final String code;
  
  AuthException(this.message, this.code);
  
  @override
  String toString() => message;
}