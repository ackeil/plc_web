import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';

class UsersProvider extends ChangeNotifier {
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  
  final List<UserEntity> _users = [];
  UserEntity? _selectedUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  UsersProvider({
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
  })  : _createUserUseCase = createUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _deleteUserUseCase = deleteUserUseCase;
  
  // Getters
  List<UserEntity> get users => _users;
  UserEntity? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  // Carregar usuário específico
  Future<void> loadUser(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Simular busca do usuário
      // Na implementação real, isso viria de um UseCase
      _selectedUser = UserEntity(
        id: userId,
        name: 'Usuário Exemplo',
        email: 'usuario@example.com',
        phone: '(11) 99999-9999',
        cpf: '123.456.789-00',
        role: 'operator',
        assignedEquipments: [],
        createdAt: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar usuário: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Criar usuário
  Future<void> createUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _createUserUseCase.execute(userData);
      
      result.fold(
        (failure) => _setError(failure.message),
        (user) {
          _users.add(user);
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro ao criar usuário: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Atualizar usuário
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _updateUserUseCase.execute(
        userId: userId,
        userData: userData,
      );
      
      result.fold(
        (failure) => _setError(failure.message),
        (user) {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = user;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError('Erro ao atualizar usuário: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Deletar usuário
  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _deleteUserUseCase.execute(userId);
      
      result.fold(
        (failure) => _setError(failure.message),
        (_) {
          _users.removeWhere((u) => u.id == userId);
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro ao deletar usuário: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Filtrar usuários
  List<dynamic> filterUsers({String? role, String? searchTerm}) {
    var filtered = _users;
    
    if (role != null && role.isNotEmpty) {
      filtered = filtered.where((u) => u.role == role).toList();
    }
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filtered = filtered.where((u) =>
        u.name.toLowerCase().contains(term) ||
        u.email.toLowerCase().contains(term)
      ).toList();
    }
    
    return filtered;
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
  
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}