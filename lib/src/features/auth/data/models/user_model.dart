import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String uid,
    required String email,
    required String name,
    required String role,
    required Map<String, bool> permissions,
    required String company,
    required bool isActive,
    bool? isMasterUser,
    required String createdAt,
  }) : super(
    id: id,
    email: email,
    name: name,
    role: role,
    isActive: isActive,
    isMasterUser: isMasterUser,
    createdAt: createdAt,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      company: json['company'] as String,
      isActive: json['isActive'] as bool,
      isMasterUser: json['isMasterUser'] as bool?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'isMasterUser': isMasterUser,
      'createdAt': createdAt,
    };
  }
}