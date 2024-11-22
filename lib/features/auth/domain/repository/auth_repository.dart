import 'package:apple_id_auth/core/utils/result.dart';

/// [AuthRepository] это интерфейс для реализации методов аутентификации.
abstract interface class AuthRepository {
  /// Метод для аутентификации через Apple ID.
  Future<Result<void>> signInWithApple();
}
