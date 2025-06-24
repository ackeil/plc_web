import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_plcweb/src/core/errors/failures.dart';
import 'package:flutter_plcweb/src/core/utils/master_auth.dart';
import 'package:flutter_plcweb/src/features/auth/data/repositories/auth_repository_impl.dart' as _authDataSource;
import 'package:flutter_plcweb/src/features/users/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

@override
Future<Either<Failure, User>> login({
  required String email,
  required String password,
}) async {
  try {
    // Verificar primeiro se é login master
    if (MasterAuth.isMasterCredentials(email, password)) {
      // Criar um usuário master local sem autenticação Firebase
      final masterUserData = MasterAuth.getMasterUserData();
      final masterUser = UserEntity.fromJson(masterUserData);
      
      // Salvar o estado de autenticação localmente
      await _saveAuthState(masterUser);
      
      return Right(masterUser);
    }
    
    // Login normal via Firebase
    final result = await _authDataSource.login(
      email: email,
      password: password,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (UserEntity) => Right(UserEntity),
    );
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

// Método auxiliar para salvar estado de autenticação
Future<void> _saveAuthState(UserEntity user) async {
  // Implementar salvamento local (SharedPreferences, Hive, etc.)
  // Exemplo:
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonEncode(user.toJson()));
  await prefs.setBool('is_logged_in', true);
  await prefs.setBool('is_master_user', user.isMasterUser ?? false);
}