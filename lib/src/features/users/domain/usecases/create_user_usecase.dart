import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class CreateUserUseCase {
  final UsersRepository repository;

  CreateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(Map<String, dynamic> userData) async {
    try {
      // Validações
      final validationError = _validateUserData(userData);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      // Criar usuário através do repositório
      return await repository.createUser(userData);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  String? _validateUserData(Map<String, dynamic> data) {
    // Validar nome
    if (data['name'] == null || data['name'].toString().isEmpty) {
      return 'Nome é obrigatório';
    }

    // Validar email
    final emailError = Validators.email(data['email']);
    if (emailError != null) {
      return emailError;
    }

    // Validar senha para novos usuários
    if (data['password'] != null) {
      final passwordError = Validators.password(data['password']);
      if (passwordError != null) {
        return passwordError;
      }
    }

    // Validar CPF se fornecido
    if (data['cpf'] != null && data['cpf'].toString().isNotEmpty) {
      final cpfError = Validators.cpf(data['cpf']);
      if (cpfError != null) {
        return cpfError;
      }
    }

    // Validar telefone se fornecido
    if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
      final phoneError = Validators.phone(data['phone']);
      if (phoneError != null) {
        return phoneError;
      }
    }

    // Validar role
    final validRoles = ['admin', 'manager', 'operator'];
    if (!validRoles.contains(data['role'])) {
      return 'Tipo de usuário inválido';
    }

    return null;
  }
}