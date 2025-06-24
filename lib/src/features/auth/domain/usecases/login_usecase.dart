import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
  }) async {
    try {
      // Validações básicas
      if (email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Email e senha são obrigatórios'));
      }

      // Chamar o repositório
      return await repository.login(
        email: email,
        password: password,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}