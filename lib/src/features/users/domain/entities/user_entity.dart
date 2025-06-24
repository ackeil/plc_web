import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? cpf;
  final String? companyId;
  final String? companyName;
  final List<String> assignedEquipments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? photoUrl;
  
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.cpf,
    this.companyId,
    this.companyName,
    this.assignedEquipments = const [],
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.isActive = true,
    this.photoUrl,
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
    companyName,
    assignedEquipments,
    createdAt,
    updatedAt,
    lastLogin,
    isActive,
    photoUrl,
  ];
  
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? cpf,
    String? companyId,
    String? companyName,
    List<String>? assignedEquipments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      assignedEquipments: assignedEquipments ?? this.assignedEquipments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
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
      'companyName': companyName,
      'assignedEquipments': assignedEquipments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'photoUrl': photoUrl,
    };
  }
}