import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class AssignEquipmentUseCase {
  final UsersRepository repository;

  AssignEquipmentUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String userId,
    required List<String> equipmentIds,
  }) async {
    try {
      // Validações
      if (userId.isEmpty) {
        return const Left(ValidationFailure('ID do usuário é obrigatório'));
      }

      // Atribuir equipamentos através do repositório
      return await repository.assignEquipments(
        userId: userId,
        equipmentIds: equipmentIds,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}