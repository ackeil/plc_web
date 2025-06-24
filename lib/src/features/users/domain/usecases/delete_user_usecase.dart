import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/users_repository.dart';

class DeleteUserUseCase {
  final UsersRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, void>> execute(String userId) async {
    try {
      // Validar ID
      if (userId.isEmpty) {
        return const Left(ValidationFailure('ID do usuário é obrigatório'));
      }

      // Deletar usuário através do repositório
      return await repository.deleteUser(userId);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}