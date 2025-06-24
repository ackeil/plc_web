import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class UpdateUserUseCase {
  final UsersRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Validações dos dados atualizados
      final validationError = _validateUpdateData(userData);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      // Atualizar usuário através do repositório
      return await repository.updateUser(
        userId: userId,
        userData: userData,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  String? _validateUpdateData(Map<String, dynamic> data) {
    // Validar nome se fornecido
    if (data.containsKey('name') && data['name'].toString().isEmpty) {
      return 'Nome não pode ser vazio';
    }

    // Validar email se fornecido
    if (data.containsKey('email')) {
      final emailError = Validators.email(data['email']);
      if (emailError != null) {
        return emailError;
      }
    }

    // Validar senha se fornecida (pode ser vazia para manter a atual)
    if (data.containsKey('password') && data['password'].toString().isNotEmpty) {
      final passwordError = Validators.password(data['password']);
      if (passwordError != null) {
        return passwordError;
      }
    }

    // Validar CPF se fornecido
    if (data.containsKey('cpf') && data['cpf'].toString().isNotEmpty) {
      final cpfError = Validators.cpf(data['cpf']);
      if (cpfError != null) {
        return cpfError;
      }
    }

    // Validar telefone se fornecido
    if (data.containsKey('phone') && data['phone'].toString().isNotEmpty) {
      final phoneError = Validators.phone(data['phone']);
      if (phoneError != null) {
        return phoneError;
      }
    }

    // Validar role se fornecido
    if (data.containsKey('role')) {
      final validRoles = ['admin', 'manager', 'operator'];
      if (!validRoles.contains(data['role'])) {
        return 'Tipo de usuário inválido';
      }
    }

    return null;
  }
}