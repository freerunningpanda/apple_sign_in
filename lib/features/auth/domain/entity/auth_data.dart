/// [AuthData] сущность для хранения ключей авторизации.
/// Для отправки запросов на сервер необходимо использовать ключи авторизации.
class AuthData {
  /// Конструктор [AuthData].
  AuthData(this.privateKey, this.publicKey);

  /// Приватный ключ.
  final String privateKey;

  /// Публичный ключ.
  final String publicKey;
}
