import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartz/dartz.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/providers/auth_provider.dart';
import 'src/features/users/presentation/providers/users_provider.dart';
import 'src/core/constants/app_colors.dart';
import 'src/core/errors/failures.dart';

// Domain imports
import 'src/features/auth/domain/entities/user.dart';
import 'src/features/auth/domain/repositories/auth_repository.dart';
import 'src/features/auth/domain/usecases/login_usecase.dart';
import 'src/features/auth/domain/usecases/logout_usecase.dart';
import 'src/features/auth/domain/usecases/recover_password_usecase.dart';
import 'src/features/users/domain/repositories/users_repository.dart';
import 'src/features/users/domain/entities/user_entity.dart';
import 'src/features/users/domain/usecases/create_user_usecase.dart';
import 'src/features/users/domain/usecases/update_user_usecase.dart';
import 'src/features/users/domain/usecases/delete_user_usecase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(MockAuthRepository()),
            logoutUseCase: LogoutUseCase(MockAuthRepository()),
            recoverPasswordUseCase: RecoverPasswordUseCase(MockAuthRepository()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UsersProvider(
            createUserUseCase: CreateUserUseCase(MockUsersRepository()),
            updateUserUseCase: UpdateUserUseCase(MockUsersRepository()),
            deleteUserUseCase: DeleteUserUseCase(MockUsersRepository()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AFT-PLC-WEB',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}

// Temporary mock implementations
class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    // Mock implementation - simula login bem-sucedido
    if (email == "admin@test.com" && password == "password123") {
      return Right(User(
        id: '1',
        name: 'Admin User',
        email: email,
        role: 'admin',
        createdAt: DateTime.now(),
      ));
    }
    return const Left(InvalidCredentialsFailure('Email ou senha incorretos'));
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> recoverPassword(String email) async {
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return const Right(null);
  }
  
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
}

class MockUsersRepository implements UsersRepository {
  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({String? role, String? companyId}) async {
    return const Right([]);
  }
  
  @override
  Future<Either<Failure, UserEntity>> getUser(String userId) async {
    return Left(UserNotFoundFailure());
  }
  
  @override
  Future<Either<Failure, UserEntity>> createUser(Map<String, dynamic> userData) async {
    return Right(UserEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: userData['name'],
      email: userData['email'],
      role: userData['role'],
      createdAt: DateTime.now(),
    ));
  }
  
  @override
  Future<Either<Failure, UserEntity>> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    return Right(UserEntity(
      id: userId,
      name: userData['name'],
      email: userData['email'],
      role: userData['role'],
      createdAt: DateTime.now(),
    ));
  }
  
  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, UserEntity>> assignEquipments({
    required String userId,
    required List<String> equipmentIds,
  }) async {
    return Left(UnknownFailure());
  }
  
  @override
  Future<Either<Failure, UserEntity>> changeUserRole({
    required String userId,
    required String newRole,
  }) async {
    return Left(UnknownFailure());
  }
  
  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    return const Right([]);
  }
}