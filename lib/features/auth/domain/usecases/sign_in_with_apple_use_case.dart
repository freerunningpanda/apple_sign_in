import 'package:apple_id_auth/core/utils/result.dart';
import 'package:apple_id_auth/core/utils/usecase.dart';
import 'package:apple_id_auth/features/auth/domain/repository/auth_repository.dart';

/// [SignInWithAppleUseCase] - кейс для аутентификации через Apple ID.
class SignInWithAppleUseCase implements Usecase<void, NoParams> {
  /// Создает [SignInWithAppleUseCase] с репозиторием [AuthRepository].
  const SignInWithAppleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.signInWithApple();
}
