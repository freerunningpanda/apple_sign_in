part of 'auth_bloc.dart';

/// [AuthState] - состояния блока аутентификации.
sealed class AuthState extends Equatable {
  /// Конструктор [AuthState]
  const AuthState();

  @override
  List<Object> get props => [];
}

/// [InitialState] - начальное состояние.
final class InitialState extends AuthState {
  /// Конструктор [InitialState]
  const InitialState();
}

/// [LoadingState] - состояние загрузки.
final class LoadingState extends AuthState {
  /// Конструктор [LoadingState]
  const LoadingState();
}

/// [SuccessState] - состояние успешной аутентификации.
final class SuccessState extends AuthState {
  /// Конструктор [SuccessState]
  const SuccessState();
}

/// [FailureState] - состояние ошибки аутентификации.
final class FailureState extends AuthState {
  /// Конструктор [FailureState]
  const FailureState(this.message);

  /// Сообщение об ошибке
  final String message;

  @override
  List<Object> get props => [message];
}
