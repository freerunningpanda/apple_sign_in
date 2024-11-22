/// [AuthRemoteDatasource] интерфейс для аутентификации
abstract interface class AuthRemoteDatasource {
  /// Метод [signInWithApple] для аутентификации через Apple ID.
  Future<void> signInWithApple();
}
