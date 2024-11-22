part of 'auth_bloc.dart';

/// [AuthEvent] - события блока аутентификации.
sealed class AuthEvent {
  /// Конструктор [AuthEvent]
  const AuthEvent();
}

/// [SignInWithAppleEvent] - событие аутентификации через Apple ID.
final class SignInWithAppleEvent extends AuthEvent {
  /// Конструктор [SignInWithAppleEvent]
  const SignInWithAppleEvent();
}
