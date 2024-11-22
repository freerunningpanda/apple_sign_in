import 'package:apple_id_auth/core/utils/result.dart';
import 'package:apple_id_auth/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apple_id_auth/features/auth/domain/repository/auth_repository.dart';

/// [AuthRepositoryImpl] - реализация [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  /// Создает [AuthRepositoryImpl] с [AuthRemoteDatasource].
  const AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      await _remoteDatasource.signInWithApple();
      return Success();
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
