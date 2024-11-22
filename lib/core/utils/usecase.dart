import 'package:apple_id_auth/core/utils/result.dart';
import 'package:equatable/equatable.dart';

/// [Usecase] это абстракция для реализации интеракторов.
abstract interface class Usecase<Type, Params> {
  /// Метод для вызова интерактора.
  Future<Result<Type>> call(Params params);
}

/// [NoParams] это класс для передачи пустых параметров.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
