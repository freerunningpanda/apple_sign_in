import 'dart:async';

/// [Result] это обертка для возвращаемых значений
/// В случае успеха [Success] или ошибки [Failure]
sealed class Result<T> {
  /// [fold] позволяет обработать результат
  Future<void> fold({
    required FutureOr<void> Function(Success<T> result) onSuccess,
    required FutureOr<void> Function(Failure<T> failure) onFailure,
  }) async =>
      switch (this) {
        final Success<T> success => await onSuccess(success),
        final Failure<T> failure => await onFailure(failure),
      };
}

/// [Success] возвращает данные
final class Success<T> extends Result<T> {
  /// Конструктор [Success]
  Success({this.data});

  /// Данные
  final T? data;
}

/// [Failure] возвращает сообщение об ошибке
final class Failure<T> extends Result<T> {
  /// Конструктор [Failure]
  Failure(this.message);

  /// Конструктор [Failure]
  final String message;
}
