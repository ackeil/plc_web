import 'package:flutter_plcweb/src/features/auth/domain/repositories/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  final AuthRepository authRepository;
  
  AuthGuard({required this.authRepository});
  
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthenticated = checkAuthentication();
    final isMasterUser = checkIfMasterUser();
    
    if (isAuthenticated || isMasterUser) {
      // Usuário autenticado ou master, permitir navegação
      resolver.next(true);
    } else {
      // Redirecionar para login
      resolver.redirect(LoginRoute());
    }
  }
  
  bool checkIfMasterUser() {
    // Verificar se é usuário master através do armazenamento local
    // Implementar conforme o método de persistência escolhido
    return false; // Implementar lógica real
  }
}