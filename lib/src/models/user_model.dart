// lib/models/user_model.dart

/// Tipos de usuário no sistema
enum UserRole {
  administrator,
  manager,
  operator
}

/// Modelo de usuário do sistema
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  
  // Campos específicos para Gerentes
  final String? companyName;
  final String? companyId;
  final bool? isManufacturer;
  
  // Campos específicos para Operadores
  final String? managerId;
  final List<String>? authorizedEquipmentIds;
  
  // Informações adicionais
  final String? lastKnownLocation;
  final String? deviceId;
  final bool emailVerified;
  final bool notificationsEnabled;
  final List<String>? notificationPreferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.companyName,
    this.companyId,
    this.isManufacturer,
    this.managerId,
    this.authorizedEquipmentIds,
    this.lastKnownLocation,
    this.deviceId,
    this.emailVerified = false,
    this.notificationsEnabled = true,
    this.notificationPreferences,
  });

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'companyName': companyName,
      'companyId': companyId,
      'isManufacturer': isManufacturer,
      'managerId': managerId,
      'authorizedEquipmentIds': authorizedEquipmentIds,
      'lastKnownLocation': lastKnownLocation,
      'deviceId': deviceId,
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
      'notificationPreferences': notificationPreferences,
    };
  }

  /// Cria a partir de um Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: _parseUserRole(map['role']),
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      isActive: map['isActive'] ?? true,
      companyName: map['companyName'],
      companyId: map['companyId'],
      isManufacturer: map['isManufacturer'],
      managerId: map['managerId'],
      authorizedEquipmentIds: map['authorizedEquipmentIds'] != null 
          ? List<String>.from(map['authorizedEquipmentIds']) 
          : null,
      lastKnownLocation: map['lastKnownLocation'],
      deviceId: map['deviceId'],
      emailVerified: map['emailVerified'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      notificationPreferences: map['notificationPreferences'] != null 
          ? List<String>.from(map['notificationPreferences']) 
          : null,
    );
  }

  /// Converte string em UserRole
  static UserRole _parseUserRole(String? role) {
    switch (role) {
      case 'administrator':
        return UserRole.administrator;
      case 'manager':
        return UserRole.manager;
      case 'operator':
        return UserRole.operator;
      default:
        return UserRole.operator;
    }
  }

  /// Cria uma cópia com campos atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? companyName,
    String? companyId,
    bool? isManufacturer,
    String? managerId,
    List<String>? authorizedEquipmentIds,
    String? lastKnownLocation,
    String? deviceId,
    bool? emailVerified,
    bool? notificationsEnabled,
    List<String>? notificationPreferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
      companyId: companyId ?? this.companyId,
      isManufacturer: isManufacturer ?? this.isManufacturer,
      managerId: managerId ?? this.managerId,
      authorizedEquipmentIds: authorizedEquipmentIds ?? this.authorizedEquipmentIds,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      deviceId: deviceId ?? this.deviceId,
      emailVerified: emailVerified ?? this.emailVerified,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }

  /// Verifica se tem acesso a um equipamento
  bool hasAccessToEquipment(String equipmentId) {
    if (role == UserRole.administrator) return true;
    if (role == UserRole.manager) return true;
    if (role == UserRole.operator && authorizedEquipmentIds != null) {
      return authorizedEquipmentIds!.contains(equipmentId);
    }
    return false;
  }

  /// Retorna o nome do role em português
  String get roleDisplayName {
    switch (role) {
      case UserRole.administrator:
        return 'Administrador';
      case UserRole.manager:
        return isManufacturer == true ? 'Fabricante' : 'Integrador';
      case UserRole.operator:
        return 'Operador';
    }
  }
}