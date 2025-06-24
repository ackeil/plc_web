import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers({
    String? role,
    String? companyId,
  });
  
  Future<Either<Failure, UserEntity>> getUser(String userId);
  
  Future<Either<Failure, UserEntity>> createUser(Map<String, dynamic> userData);
  
  Future<Either<Failure, UserEntity>> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  });
  
  Future<Either<Failure, void>> deleteUser(String userId);
  
  Future<Either<Failure, UserEntity>> assignEquipments({
    required String userId,
    required List<String> equipmentIds,
  });
  
  Future<Either<Failure, UserEntity>> changeUserRole({
    required String userId,
    required String newRole,
  });
  
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);
}