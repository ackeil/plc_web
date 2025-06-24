class UserRole {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String operator = 'operator';
  
  static List<String> get all => [admin, manager, operator];
  
  static String getDisplayName(String role) {
    switch (role) {
      case admin:
        return 'Administrador';
      case manager:
        return 'Gerente';
      case operator:
        return 'Operador';
      default:
        return role;
    }
  }
  
  static String getDescription(String role) {
    switch (role) {
      case admin:
        return 'Acesso total ao sistema, pode gerenciar usuários e equipamentos';
      case manager:
        return 'Pode gerenciar operadores e equipamentos da sua empresa';
      case operator:
        return 'Pode operar equipamentos e enviar dados';
      default:
        return '';
    }
  }
  
  static int getHierarchyLevel(String role) {
    switch (role) {
      case admin:
        return 3;
      case manager:
        return 2;
      case operator:
        return 1;
      default:
        return 0;
    }
  }
  
  static bool canManageRole(String userRole, String targetRole) {
    final userLevel = getHierarchyLevel(userRole);
    final targetLevel = getHierarchyLevel(targetRole);
    
    return userLevel > targetLevel;
  }
}