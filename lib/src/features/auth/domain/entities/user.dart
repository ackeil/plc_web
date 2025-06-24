import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? cpf;
  final String? companyId;
  final List<String> assignedEquipments;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.cpf,
    this.companyId,
    this.assignedEquipments = const [],
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    phone,
    cpf,
    companyId,
    assignedEquipments,
    createdAt,
    lastLogin,
    isActive,
  ];
  
  // Método para verificar permissões
  bool hasPermission(String requiredRole) {
    final userLevel = _getRoleLevel(role);
    final requiredLevel = _getRoleLevel(requiredRole);
    return userLevel >= requiredLevel;
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
  
  // Verificar se é admin
  bool get isAdmin => role == 'admin';
  
  // Verificar se é gerente
  bool get isManager => role == 'manager';
  
  // Verificar se é operador
  bool get isOperator => role == 'operator';
  
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? cpf,
    String? companyId,
    List<String>? assignedEquipments,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      companyId: companyId ?? this.companyId,
      assignedEquipments: assignedEquipments ?? this.assignedEquipments,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'cpf': cpf,
      'companyId': companyId,
      'assignedEquipments': assignedEquipments,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'operator',
      phone: map['phone'],
      cpf: map['cpf'],
      companyId: map['companyId'],
      assignedEquipments: List<String>.from(map['assignedEquipments'] ?? []),
      createdAt: map['createdAt'] != null 
        ? DateTime.parse(map['createdAt']) 
        : DateTime.now(),
      lastLogin: map['lastLogin'] != null 
        ? DateTime.parse(map['lastLogin']) 
        : null,
      isActive: map['isActive'] ?? true,
    );
  }
}