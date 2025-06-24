import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class RecoverPasswordUseCase {
  final AuthRepository repository;

  RecoverPasswordUseCase(this.repository);

  Future<Either<Failure, void>> execute(String email) async {
    try {
      // Validar email
      final emailError = Validators.email(email);
      if (emailError != null) {
        return Left(ValidationFailure(emailError));
      }

      // Chamar o repositório
      return await repository.recoverPassword(email);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}