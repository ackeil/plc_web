import 'package:flutter/foundation.dart';

/// Classe para gerenciar credenciais master do sistema
class MasterAuth {
  // Credenciais master hardcoded para desenvolvimento/demonstração
  static const String MASTER_EMAIL = 'master@alfatronic.com.br';
  static const String MASTER_PASSWORD = 'AFT@Master2025';
  static const String MASTER_UID = 'master-admin-uid';
  
  // Dados do usuário master
  static const Map<String, dynamic> MASTER_USER_DATA = {
    'uid': MASTER_UID,
    'email': MASTER_EMAIL,
    'name': 'Master Administrator',
    'role': 'administrator',
    'permissions': {
      'canCreateManagers': true,
      'canCreateOperators': true,
      'canDeleteUsers': true,
      'canManageEquipment': true,
      'canViewAllData': true,
      'canExportReports': true,
      'canAccessAllCompanies': true,
    },
    'company': 'Alfatronic',
    'isActive': true,
    'isMasterUser': true,
    'createdAt': '2025-01-01T00:00:00Z',
  };
  
  /// Verifica se as credenciais fornecidas são as credenciais master
  static bool isMasterCredentials(String email, String password) {
    return email == MASTER_EMAIL && password == MASTER_PASSWORD;
  }
  
  /// Retorna os dados do usuário master
  static Map<String, dynamic> getMasterUserData() {
    return Map<String, dynamic>.from(MASTER_USER_DATA);
  }
}
