import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, LoginResponse>> call(LoginRequest request) async {
    // Validation
    if (request.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email không được để trống'));
    }

    if (!_isValidEmail(request.email)) {
      return const Left(ValidationFailure('Email không hợp lệ'));
    }

    if (request.password.trim().isEmpty) {
      return const Left(ValidationFailure('Mật khẩu không được để trống'));
    }

    if (request.password.length < 6) {
      return const Left(ValidationFailure('Mật khẩu phải có ít nhất 6 ký tự'));
    }

    return await _repository.login(request);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, User?>> call() async {
    return await _repository.getCurrentUser();
  }
}

class IsLoggedInUseCase {
  final AuthRepository _repository;

  IsLoggedInUseCase(this._repository);

  Future<Either<Failure, bool>> call() async {
    return await _repository.isLoggedIn();
  }
}

class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<Either<Failure, User?>> call() async {
    return await _repository.refreshToken();
  }
}

// Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isLoggedInUseCaseProvider = Provider<IsLoggedInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsLoggedInUseCase(repository);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});
