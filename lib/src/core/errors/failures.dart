import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erro de conexão']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro no cache']);
}

// Auth failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Erro de autenticação']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Credenciais inválidas']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Não autorizado']);
}

// User failures
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'Usuário não encontrado']);
}

class UserAlreadyExistsFailure extends Failure {
  const UserAlreadyExistsFailure([super.message = 'Usuário já existe']);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Erro de validação']);
}

// Generic failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Erro desconhecido']);
}