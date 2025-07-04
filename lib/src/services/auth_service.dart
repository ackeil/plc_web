import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

/// Exceções customizadas para melhor tratamento de erros
class AuthException implements Exception {
  final String message;
  final String code;
  
  AuthException(this.message, this.code);
  
  @override
  String toString() => message;
}

/// Serviço principal de autenticação do sistema AFT-PLC-WEB
/// 
/// Este serviço gerencia todo o ciclo de vida dos usuários, desde login até
/// recuperação de senha, respeitando a hierarquia de três níveis do sistema.
class AuthService {
  // Instâncias dos serviços Firebase
  final FirebaseAuth _auth = FirebaseConfig.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  
  // Controle de tentativas de login para segurança
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(hours: 1);
  
  // ===== MODO DEMONSTRAÇÃO =====
  // Credenciais do usuário mestre para demonstração offline
  static const String demoEmail = 'teste@ucs.br';
  static const String demoPassword = 'Teste123';
  
  // Flag para indicar se estamos em modo demo
  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;
  
  // Usuário demo mockado com todas as permissões
  final UserModel _demoUser = UserModel(
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
    notificationPreferences: ['email', 'push'],
  );
  
  // Lista mockada de usuários para demonstração
  final List<UserModel> _demoUsers = [
    UserModel(
      id: 'demo-manager-001',
      email: 'gerente1@demo.com',
      name: 'João Silva',
      phoneNumber: '(54) 98888-8888',
      role: UserRole.manager,
      createdAt: DateTime(2024, 2, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      companyName: 'Empresa ABC Equipamentos',
      companyId: 'empresa-abc',
      isManufacturer: true,
      emailVerified: true,
      notificationsEnabled: true,
    ),
    UserModel(
      id: 'demo-manager-002',
      email: 'gerente2@demo.com',
      name: 'Maria Santos',
      phoneNumber: '(54) 97777-7777',
      role: UserRole.manager,
      createdAt: DateTime(2024, 2, 15),
      lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      isActive: true,
      companyName: 'Integrador XYZ',
      companyId: 'integrador-xyz',
      isManufacturer: false,
      emailVerified: true,
      notificationsEnabled: true,
    ),
    UserModel(
      id: 'demo-operator-001',
      email: 'operador1@demo.com',
      name: 'Carlos Oliveira',
      phoneNumber: '(54) 96666-6666',
      role: UserRole.operator,
      createdAt: DateTime(2024, 3, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
      isActive: true,
      companyName: 'Empresa ABC Equipamentos',
      companyId: 'empresa-abc',
      managerId: 'demo-manager-001',
      authorizedEquipmentIds: ['equip-001', 'equip-002', 'equip-003'],
      emailVerified: true,
      notificationsEnabled: true,
    ),
    UserModel(
      id: 'demo-operator-002',
      email: 'operador2@demo.com',
      name: 'Ana Paula',
      phoneNumber: '(54) 95555-5555',
      role: UserRole.operator,
      createdAt: DateTime(2024, 3, 10),
      lastLogin: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
      companyName: 'Empresa ABC Equipamentos',
      companyId: 'empresa-abc',
      managerId: 'demo-manager-001',
      authorizedEquipmentIds: ['equip-002', 'equip-004'],
      emailVerified: true,
      notificationsEnabled: false,
    ),
    UserModel(
      id: 'demo-operator-003',
      email: 'operador3@demo.com',
      name: 'Roberto Costa',
      phoneNumber: '(54) 94444-4444',
      role: UserRole.operator,
      createdAt: DateTime(2024, 3, 20),
      lastLogin: DateTime.now().subtract(const Duration(days: 7)),
      isActive: false, // Operador desativado para demonstrar funcionalidade
      companyName: 'Integrador XYZ',
      companyId: 'integrador-xyz',
      managerId: 'demo-manager-002',
      authorizedEquipmentIds: ['equip-005'],
      emailVerified: true,
      notificationsEnabled: true,
    ),
  ];
  
  // Stream do usuário atual para reactive updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Getter para o usuário atual do Firebase
  User? get currentUser => _auth.currentUser;
  
  // Cache local do modelo completo do usuário
  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;
  
  /// Obtém o modelo completo do usuário atual do Firestore
  /// 
  /// Este método é crucial pois o FirebaseAuth só nos dá informações básicas,
  /// mas precisamos dos dados completos (role, empresa, etc) para o sistema funcionar
  Future<UserModel?> getCurrentUserModel() async {
    try {
      // Em modo demo, retorna o usuário demo
      if (_isDemoMode) {
        return _demoUser;
      }
      
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();
          
      if (!doc.exists) {
        print('AuthService: Usuário autenticado mas sem dados no Firestore');
        return null;
      }
      
      _currentUserModel = UserModel.fromMap(doc.data()!);
      return _currentUserModel;
    } catch (e) {
      print('AuthService: Erro ao buscar dados do usuário: $e');
      return null;
    }
  }
  
  /// Realiza o login do usuário com email e senha
  /// 
  /// Este método não só autentica o usuário, mas também:
  /// - Verifica se a conta está ativa
  /// - Controla tentativas de login falhas
  /// - Atualiza o último login
  /// - Carrega o modelo completo do usuário
  /// - Suporta modo demo para apresentações offline
  Future<UserModel> signIn({
    required String email, 
    required String password,
  }) async {
    try {
      // ===== MODO DEMONSTRAÇÃO =====
      // Verifica se é o usuário demo
      if (email.toLowerCase() == demoEmail && password == demoPassword) {
        print('AuthService: Modo demonstração ativado');
        _isDemoMode = true;
        _currentUserModel = _demoUser;
        
        // Simula um pequeno delay para parecer mais real
        await Future.delayed(const Duration(milliseconds: 800));
        
        return _demoUser;
      }
      
      // Se tentou fazer login com outro usuário mas estava em modo demo,
      // desativa o modo demo
      if (_isDemoMode) {
        _isDemoMode = false;
        _currentUserModel = null;
      }
      // ===== FIM MODO DEMONSTRAÇÃO =====
      
      // Primeiro, verifica se a conta está bloqueada por tentativas excessivas
      await _checkAccountLockout(email);
      
      // Tenta fazer o login no Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException(
          'Erro ao fazer login. Tente novamente.',
          'login-failed',
        );
      }
      
      // Busca os dados completos do usuário no Firestore
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(credential.user!.uid)
          .get();
          
      if (!userDoc.exists) {
        // Usuário existe no Auth mas não no Firestore - situação anormal
        await _auth.signOut();
        throw AuthException(
          'Dados do usuário não encontrados. Contate o administrador.',
          'user-data-not-found',
        );
      }
      
      final userData = userDoc.data()!;
      final userModel = UserModel.fromMap(userData);
      
      // Verifica se a conta está ativa
      if (!userModel.isActive) {
        await _auth.signOut();
        throw AuthException(
          'Esta conta foi desativada. Contate seu gerente.',
          'account-disabled',
        );
      }
      
      // Atualiza informações de login bem-sucedido
      await _updateLoginSuccess(userModel);
      
      _currentUserModel = userModel;
      return userModel;
      
    } on FirebaseAuthException catch (e) {
      // Registra tentativa falha de login
      await _recordFailedLogin(email);
      
      // Traduz erros do Firebase para mensagens amigáveis
      switch (e.code) {
        case 'user-not-found':
          throw AuthException(
            'Email não cadastrado no sistema.',
            e.code,
          );
        case 'wrong-password':
          throw AuthException(
            'Senha incorreta. Verifique e tente novamente.',
            e.code,
          );
        case 'invalid-email':
          throw AuthException(
            'Email inválido. Verifique o formato.',
            e.code,
          );
        case 'user-disabled':
          throw AuthException(
            'Esta conta foi desabilitada.',
            e.code,
          );
        default:
          throw AuthException(
            'Erro ao fazer login: ${e.message}',
            e.code,
          );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro inesperado ao fazer login. Tente novamente.',
        'unknown-error',
      );
    }
  }
  
  /// Realiza o logout do usuário
  /// 
  /// Limpa todos os dados em cache e encerra a sessão
  Future<void> signOut() async {
    try {
      // Se está em modo demo, apenas limpa os dados locais
      if (_isDemoMode) {
        _isDemoMode = false;
        _currentUserModel = null;
        print('AuthService: Saindo do modo demonstração');
        return;
      }
      
      await _auth.signOut();
      _currentUserModel = null;
    } catch (e) {
      throw AuthException(
        'Erro ao fazer logout. Tente novamente.',
        'signout-failed',
      );
    }
  }
  
  /// Cria uma nova conta de usuário
  /// 
  /// Este método respeita a hierarquia do sistema:
  /// - Administradores podem criar gerentes e operadores
  /// - Gerentes podem criar apenas operadores
  /// - Operadores não podem criar contas
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String? companyName,
    String? companyId,
    bool? isManufacturer,
    List<String>? authorizedEquipmentIds,
  }) async {
    try {
      // Verifica permissões do usuário atual
      final currentUser = await getCurrentUserModel();
      if (currentUser == null) {
        throw AuthException(
          'Você precisa estar logado para criar usuários.',
          'not-authenticated',
        );
      }
      
      // Valida permissões baseadas na hierarquia
      _validateCreateUserPermission(currentUser, role);
      
      // Cria o usuário no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException(
          'Erro ao criar conta. Tente novamente.',
          'user-creation-failed',
        );
      }
      
      // Prepara os dados do novo usuário
      final newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
        companyName: companyName ?? currentUser.companyName,
        companyId: companyId ?? currentUser.companyId,
        isManufacturer: isManufacturer,
        managerId: role == UserRole.operator ? currentUser.id : null,
        authorizedEquipmentIds: authorizedEquipmentIds,
        emailVerified: false,
        notificationsEnabled: true,
      );
      
      // Salva os dados no Firestore
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(newUser.id)
          .set(newUser.toMap());
      
      // Envia email de verificação
      await credential.user!.sendEmailVerification();
      
      // Faz logout do novo usuário para manter o usuário atual logado
      await _auth.signOut();
      
      // Reloga o usuário que estava criando a conta
      if (currentUser.email != null) {
        // Nota: Em produção, você deve armazenar o token de autenticação
        // de forma segura em vez de pedir a senha novamente
        print('AuthService: Novo usuário criado. Faça login novamente.');
      }
      
      return newUser;
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException(
            'Este email já está cadastrado no sistema.',
            e.code,
          );
        case 'invalid-email':
          throw AuthException(
            'Email inválido. Verifique o formato.',
            e.code,
          );
        case 'weak-password':
          throw AuthException(
            'Senha muito fraca. Use pelo menos 6 caracteres.',
            e.code,
          );
        default:
          throw AuthException(
            'Erro ao criar usuário: ${e.message}',
            e.code,
          );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro inesperado ao criar usuário.',
        'unknown-error',
      );
    }
  }
  
  /// Atualiza dados de um usuário existente
  /// 
  /// Respeita as mesmas regras de hierarquia da criação
  Future<void> updateUser({
    required String userId,
    String? name,
    String? phoneNumber,
    bool? isActive,
    List<String>? authorizedEquipmentIds,
    bool? notificationsEnabled,
    List<String>? notificationPreferences,
  }) async {
    try {
      // Verifica permissões
      final currentUser = await getCurrentUserModel();
      if (currentUser == null) {
        throw AuthException(
          'Você precisa estar logado para atualizar usuários.',
          'not-authenticated',
        );
      }
      
      // Busca o usuário a ser atualizado
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();
          
      if (!userDoc.exists) {
        throw AuthException(
          'Usuário não encontrado.',
          'user-not-found',
        );
      }
      
      final targetUser = UserModel.fromMap(userDoc.data()!);
      
      // Valida permissões
      _validateUpdateUserPermission(currentUser, targetUser);
      
      // Prepara os dados para atualização
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (isActive != null) updates['isActive'] = isActive;
      if (authorizedEquipmentIds != null) {
        updates['authorizedEquipmentIds'] = authorizedEquipmentIds;
      }
      if (notificationsEnabled != null) {
        updates['notificationsEnabled'] = notificationsEnabled;
      }
      if (notificationPreferences != null) {
        updates['notificationPreferences'] = notificationPreferences;
      }
      
      // Atualiza no Firestore
      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userId)
            .update(updates);
      }
      
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro ao atualizar usuário.',
        'update-failed',
      );
    }
  }
  
  /// Deleta um usuário do sistema
  /// 
  /// Remove tanto do Firebase Auth quanto do Firestore
  Future<void> deleteUser(String userId) async {
    try {
      // Verifica permissões
      final currentUser = await getCurrentUserModel();
      if (currentUser == null) {
        throw AuthException(
          'Você precisa estar logado para deletar usuários.',
          'not-authenticated',
        );
      }
      
      // Não permite deletar a própria conta
      if (currentUser.id == userId) {
        throw AuthException(
          'Você não pode deletar sua própria conta.',
          'cannot-delete-self',
        );
      }
      
      // Busca o usuário a ser deletado
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();
          
      if (!userDoc.exists) {
        throw AuthException(
          'Usuário não encontrado.',
          'user-not-found',
        );
      }
      
      final targetUser = UserModel.fromMap(userDoc.data()!);
      
      // Valida permissões
      _validateDeleteUserPermission(currentUser, targetUser);
      
      // Remove do Firestore primeiro
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .delete();
      
      // TODO: Implementar Cloud Function para deletar do Firebase Auth
      // Por segurança, apenas Admin SDK pode deletar usuários do Auth
      
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro ao deletar usuário.',
        'delete-failed',
      );
    }
  }
  
  /// Inicia o processo de recuperação de senha
  /// 
  /// Para operadores, requer aprovação do gerente
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Busca o usuário pelo email
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isEmpty) {
        // Por segurança, não revelamos se o email existe ou não
        return;
      }
      
      final userData = querySnapshot.docs.first.data();
      final userModel = UserModel.fromMap(userData);
      
      // Se for operador, precisa de aprovação do gerente
      if (userModel.role == UserRole.operator && userModel.managerId != null) {
        // TODO: Implementar sistema de notificação para o gerente
        // Por enquanto, vamos enviar direto
        print('AuthService: Operador solicitou reset. Notificar gerente: ${userModel.managerId}');
      }
      
      // Envia o email de recuperação
      await _auth.sendPasswordResetEmail(email: email);
      
    } catch (e) {
      // Por segurança, não revelamos detalhes do erro
      print('AuthService: Erro ao enviar email de recuperação: $e');
    }
  }
  
  /// Verifica e atualiza o status de verificação do email
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Recarrega o usuário para obter status atualizado
      await user.reload();
      
      if (user.emailVerified) {
        // Atualiza no Firestore
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(user.uid)
            .update({'emailVerified': true});
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('AuthService: Erro ao verificar email: $e');
      return false;
    }
  }
  
  /// Reenvia o email de verificação
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(
          'Nenhum usuário logado.',
          'no-user',
        );
      }
      
      if (user.emailVerified) {
        throw AuthException(
          'Email já verificado.',
          'already-verified',
        );
      }
      
      await user.sendEmailVerification();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro ao enviar email de verificação.',
        'verification-failed',
      );
    }
  }
  
  /// Atualiza a senha do usuário atual
  /// 
  /// Requer a senha atual por segurança
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw AuthException(
          'Nenhum usuário logado.',
          'no-user',
        );
      }
      
      // Re-autentica o usuário
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Atualiza a senha
      await user.updatePassword(newPassword);
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw AuthException(
            'Senha atual incorreta.',
            e.code,
          );
        case 'weak-password':
          throw AuthException(
            'Nova senha muito fraca. Use pelo menos 6 caracteres.',
            e.code,
          );
        default:
          throw AuthException(
            'Erro ao atualizar senha: ${e.message}',
            e.code,
          );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Erro ao atualizar senha.',
        'update-password-failed',
      );
    }
  }
  
  // ===== MÉTODOS PRIVADOS DE SUPORTE =====
  
  /// Valida se o usuário atual pode criar um usuário do tipo especificado
  void _validateCreateUserPermission(UserModel currentUser, UserRole newUserRole) {
    switch (currentUser.role) {
      case UserRole.administrator:
        // Admin pode criar qualquer tipo de usuário
        return;
      case UserRole.manager:
        // Gerente só pode criar operadores
        if (newUserRole != UserRole.operator) {
          throw AuthException(
            'Gerentes só podem criar contas de operadores.',
            'insufficient-permissions',
          );
        }
        return;
      case UserRole.operator:
        // Operador não pode criar usuários
        throw AuthException(
          'Operadores não têm permissão para criar usuários.',
          'insufficient-permissions',
        );
    }
  }
  
  /// Valida se o usuário atual pode atualizar o usuário alvo
  void _validateUpdateUserPermission(UserModel currentUser, UserModel targetUser) {
    switch (currentUser.role) {
      case UserRole.administrator:
        // Admin pode atualizar qualquer usuário
        return;
      case UserRole.manager:
        // Gerente só pode atualizar operadores sob sua gestão
        if (targetUser.role != UserRole.operator || 
            targetUser.managerId != currentUser.id) {
          throw AuthException(
            'Você só pode atualizar operadores sob sua gestão.',
            'insufficient-permissions',
          );
        }
        return;
      case UserRole.operator:
        // Operador só pode atualizar alguns dados próprios
        if (targetUser.id != currentUser.id) {
          throw AuthException(
            'Você só pode atualizar seus próprios dados.',
            'insufficient-permissions',
          );
        }
        return;
    }
  }
  
  /// Valida se o usuário atual pode deletar o usuário alvo
  void _validateDeleteUserPermission(UserModel currentUser, UserModel targetUser) {
    switch (currentUser.role) {
      case UserRole.administrator:
        // Admin pode deletar qualquer usuário (exceto si mesmo)
        return;
      case UserRole.manager:
        // Gerente só pode deletar operadores sob sua gestão
        if (targetUser.role != UserRole.operator || 
            targetUser.managerId != currentUser.id) {
          throw AuthException(
            'Você só pode deletar operadores sob sua gestão.',
            'insufficient-permissions',
          );
        }
        return;
      case UserRole.operator:
        // Operador não pode deletar usuários
        throw AuthException(
          'Operadores não têm permissão para deletar usuários.',
          'insufficient-permissions',
        );
    }
  }
  
  /// Verifica se a conta está bloqueada por tentativas excessivas
  Future<void> _checkAccountLockout(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isEmpty) return;
      
      final userData = querySnapshot.docs.first.data();
      final userModel = UserModel.fromMap(userData);
      
      if (userModel.isLocked) {
        final remainingTime = userModel.lockedUntil!.difference(DateTime.now());
        throw AuthException(
          'Conta bloqueada por excesso de tentativas. '
          'Tente novamente em ${remainingTime.inMinutes} minutos.',
          'account-locked',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      // Se houver erro ao verificar, permitimos a tentativa de login
      print('AuthService: Erro ao verificar bloqueio: $e');
    }
  }
  
  /// Registra uma tentativa falha de login
  Future<void> _recordFailedLogin(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isEmpty) return;
      
      final doc = querySnapshot.docs.first;
      final userData = doc.data();
      final userModel = UserModel.fromMap(userData);
      
      final newFailedAttempts = (userModel.failedLoginAttempts ?? 0) + 1;
      
      if (newFailedAttempts >= maxLoginAttempts) {
        // Bloqueia a conta
        await doc.reference.update({
          'failedLoginAttempts': newFailedAttempts,
          'lockedUntil': Timestamp.fromDate(
            DateTime.now().add(lockoutDuration),
          ),
        });
      } else {
        // Apenas incrementa o contador
        await doc.reference.update({
          'failedLoginAttempts': newFailedAttempts,
        });
      }
    } catch (e) {
      print('AuthService: Erro ao registrar tentativa falha: $e');
    }
  }
  
  /// Atualiza informações após login bem-sucedido
  Future<void> _updateLoginSuccess(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.id)
          .update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
        'failedLoginAttempts': 0,
        'lockedUntil': null,
      });
    } catch (e) {
      print('AuthService: Erro ao atualizar login bem-sucedido: $e');
    }
  }
  
  // ===== MÉTODOS AUXILIARES PARA MODO DEMONSTRAÇÃO =====
  
  /// Retorna lista de todos os usuários disponíveis no modo demo
  /// 
  /// Este método simula a busca de usuários no Firestore, retornando
  /// dados mockados quando em modo demonstração
  Future<List<UserModel>> getAllUsers() async {
    if (_isDemoMode) {
      // Simula delay de rede
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Retorna lista completa incluindo o admin demo
      final allUsers = [_demoUser, ..._demoUsers];
      
      // Filtra baseado no role do usuário atual
      if (_currentUserModel?.role == UserRole.manager) {
        // Gerente vê apenas usuários da sua empresa
        return allUsers.where((user) => 
          user.companyId == _currentUserModel!.companyId ||
          user.id == _currentUserModel!.id
        ).toList();
      }
      
      return allUsers;
    }
    
    // Modo real - busca no Firestore
    try {
      final currentUser = await getCurrentUserModel();
      if (currentUser == null) return [];
      
      Query query = _firestore.collection(FirebaseConfig.usersCollection);
      
      // Aplica filtros baseados no role
      if (currentUser.role == UserRole.manager) {
        query = query.where('companyId', isEqualTo: currentUser.companyId);
      } else if (currentUser.role == UserRole.operator) {
        // Operador vê apenas a si mesmo
        return [currentUser];
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('AuthService: Erro ao buscar usuários: $e');
      return [];
    }
  }
  
  /// Retorna lista de operadores de um gerente específico
  /// 
  /// Útil para gerentes visualizarem seus operadores subordinados
  Future<List<UserModel>> getOperatorsByManager(String managerId) async {
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _demoUsers
          .where((user) => 
            user.role == UserRole.operator && 
            user.managerId == managerId
          )
          .toList();
    }
    
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: 'operator')
          .where('managerId', isEqualTo: managerId)
          .get();
          
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('AuthService: Erro ao buscar operadores: $e');
      return [];
    }
  }
  
  /// Busca um usuário específico pelo ID
  Future<UserModel?> getUserById(String userId) async {
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (userId == _demoUser.id) return _demoUser;
      
      try {
        return _demoUsers.firstWhere((user) => user.id == userId);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();
          
      if (!doc.exists) return null;
      
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      print('AuthService: Erro ao buscar usuário por ID: $e');
      return null;
    }
  }
  
  /// Simula criação de usuário em modo demo
  /// 
  /// Em modo demo, apenas adiciona à lista local temporariamente
  @override
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String? companyName,
    String? companyId,
    bool? isManufacturer,
    List<String>? authorizedEquipmentIds,
  }) async {
    // Se está em modo demo, simula a criação
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Valida permissões mesmo em modo demo
      _validateCreateUserPermission(_currentUserModel!, role);
      
      // Cria um novo usuário demo
      final newUser = UserModel(
        id: 'demo-temp-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
        companyName: companyName ?? _currentUserModel!.companyName,
        companyId: companyId ?? _currentUserModel!.companyId,
        isManufacturer: isManufacturer,
        managerId: role == UserRole.operator ? _currentUserModel!.id : null,
        authorizedEquipmentIds: authorizedEquipmentIds,
        emailVerified: true, // Em demo, sempre verificado
        notificationsEnabled: true,
      );
      
      // Adiciona à lista temporariamente (não persiste entre sessões)
      _demoUsers.add(newUser);
      
      print('AuthService Demo: Usuário criado temporariamente - ${newUser.email}');
      return newUser;
    }
    
    // Implementação real já existente continua aqui...
    return super.createUser(
      email: email,
      password: password,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
      companyName: companyName,
      companyId: companyId,
      isManufacturer: isManufacturer,
      authorizedEquipmentIds: authorizedEquipmentIds,
    );
  }
  
  /// Verifica se está em modo demonstração
  /// 
  /// Útil para a UI mostrar indicadores visuais de modo demo
  bool get isInDemoMode => _isDemoMode;
  
  /// Retorna informações sobre o modo demo para debug
  Map<String, dynamic> getDemoInfo() {
    return {
      'isDemoMode': _isDemoMode,
      'demoEmail': demoEmail,
      'totalDemoUsers': _demoUsers.length + 1, // +1 para o admin
      'currentUser': _currentUserModel?.email,
      'currentRole': _currentUserModel?.role.toString(),
    };
  }
}