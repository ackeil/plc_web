import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    try {
      return await repository.logout();
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}