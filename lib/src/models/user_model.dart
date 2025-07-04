import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum para definir os tipos de usuário no sistema
enum UserRole {
  administrator, // Administrador do sistema (Alfatronic)
  manager,      // Gerente (Fabricante/Integrador)
  operator      // Operador de equipamentos
}

/// Modelo principal de usuário do sistema AFT-PLC-WEB
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
  final bool? isManufacturer; // true = Fabricante, false = Integrador
  
  // Campos específicos para Operadores
  final String? managerId; // ID do gerente responsável
  final List<String>? authorizedEquipmentIds; // Equipamentos autorizados
  
  // Informações de localização e dispositivo
  final String? lastKnownLocation;
  final String? deviceId; // ID do dispositivo móvel pareado
  final String? bluetoothMac; // MAC address para pareamento
  
  // Controle de acesso e segurança
  final bool emailVerified;
  final int? failedLoginAttempts;
  final DateTime? lockedUntil;
  
  // Configurações de notificação
  final bool notificationsEnabled;
  final String? fcmToken; // Token para push notifications
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
    this.bluetoothMac,
    this.emailVerified = false,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.notificationsEnabled = true,
    this.fcmToken,
    this.notificationPreferences,
  });

  /// Converte o modelo para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'companyName': companyName,
      'companyId': companyId,
      'isManufacturer': isManufacturer,
      'managerId': managerId,
      'authorizedEquipmentIds': authorizedEquipmentIds,
      'lastKnownLocation': lastKnownLocation,
      'deviceId': deviceId,
      'bluetoothMac': bluetoothMac,
      'emailVerified': emailVerified,
      'failedLoginAttempts': failedLoginAttempts,
      'lockedUntil': lockedUntil != null ? Timestamp.fromDate(lockedUntil!) : null,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
      'notificationPreferences': notificationPreferences,
    };
  }

  /// Cria um modelo a partir de um Map do Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: _parseUserRole(map['role']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null 
          ? (map['lastLogin'] as Timestamp).toDate() 
          : null,
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
      bluetoothMac: map['bluetoothMac'],
      emailVerified: map['emailVerified'] ?? false,
      failedLoginAttempts: map['failedLoginAttempts'] ?? 0,
      lockedUntil: map['lockedUntil'] != null 
          ? (map['lockedUntil'] as Timestamp).toDate() 
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      fcmToken: map['fcmToken'],
      notificationPreferences: map['notificationPreferences'] != null 
          ? List<String>.from(map['notificationPreferences']) 
          : null,
    );
  }

  /// Método auxiliar para converter string em UserRole
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

  /// Cria uma cópia do modelo com campos atualizados
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
    String? bluetoothMac,
    bool? emailVerified,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    bool? notificationsEnabled,
    String? fcmToken,
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
      bluetoothMac: bluetoothMac ?? this.bluetoothMac,
      emailVerified: emailVerified ?? this.emailVerified,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }

  /// Verifica se o usuário tem permissão para acessar um equipamento
  bool hasAccessToEquipment(String equipmentId) {
    if (role == UserRole.administrator) return true;
    if (role == UserRole.manager) return true; // Gerente vê todos da empresa
    if (role == UserRole.operator && authorizedEquipmentIds != null) {
      return authorizedEquipmentIds!.contains(equipmentId);
    }
    return false;
  }

  /// Verifica se a conta está bloqueada por tentativas de login
  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Retorna o nome do role em português para exibição
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
