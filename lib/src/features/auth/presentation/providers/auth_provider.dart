import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/recover_password_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RecoverPasswordUseCase _recoverPasswordUseCase;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RecoverPasswordUseCase recoverPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _recoverPasswordUseCase = recoverPasswordUseCase;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _loginUseCase.execute(
        email: email,
        password: password,
      );
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (user) {
          _currentUser = user;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao fazer login: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      final result = await _logoutUseCase.execute();
      
      result.fold(
        (failure) => _setError(failure.message),
        (_) {
          _currentUser = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro ao fazer logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Recuperar senha
  Future<bool> recoverPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _recoverPasswordUseCase.execute(email);
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      _setError('Erro ao recuperar senha: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Verificar se usuário tem permissão
  bool hasPermission(String requiredRole) {
    if (_currentUser == null) return false;
    
    // Implementar lógica de hierarquia de permissões
    final userRoleLevel = _getRoleLevel(_currentUser!.role);
    final requiredRoleLevel = _getRoleLevel(requiredRole);
    
    return userRoleLevel >= requiredRoleLevel;
  }
  
  int _getRoleLevel(String role) {
    switch (role) {
      case 'admin':
        return 3;
      case 'manager':
        return 2;
      case 'operator':
        return 1;
      default:
        return 0;
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}