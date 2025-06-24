import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, void>> recoverPassword(String email);
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Stream<User?> get authStateChanges;
}