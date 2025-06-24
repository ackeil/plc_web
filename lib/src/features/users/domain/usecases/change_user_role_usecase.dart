import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/users_repository.dart';

class ChangeUserRoleUseCase {
  final UsersRepository repository;

  ChangeUserRoleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String userId,
    required String newRole,
    required String currentUserRole,
  }) async {
    try {
      // Validações
      if (userId.isEmpty) {
        return const Left(ValidationFailure('ID do usuário é obrigatório'));
      }

      // Verificar se o role é válido
      if (!UserRole.all.contains(newRole)) {
        return const Left(ValidationFailure('Tipo de usuário inválido'));
      }

      // Verificar se o usuário atual tem permissão para alterar para este role
      if (!UserRole.canManageRole(currentUserRole, newRole)) {
        return const Left(UnauthorizedFailure('Você não tem permissão para atribuir este tipo de usuário'));
      }

      // Alterar role através do repositório
      return await repository.changeUserRole(
        userId: userId,
        newRole: newRole,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}