import 'package:apple_id_auth/core/utils/usecase.dart';
import 'package:apple_id_auth/features/auth/domain/usecases/sign_in_with_apple_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// [AuthBloc] - блок аутентификации.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Создает [AuthBloc] с [SignInWithAppleUseCase].
  AuthBloc(this._signInWithAppleUseCase) : super(const InitialState()) {
    on<SignInWithAppleEvent>(_onSignInWithApple);
  }

  final SignInWithAppleUseCase _signInWithAppleUseCase;

  Future<void> _onSignInWithApple(
    SignInWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoadingState());
    final result = await _signInWithAppleUseCase(NoParams());

    await result.fold(
      onSuccess: (_) => emit(const SuccessState()),
      onFailure: (failure) => emit(FailureState(failure.message)),
    );
  }
}
