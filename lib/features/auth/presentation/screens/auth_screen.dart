import 'package:apple_id_auth/core/presentation/router/app_router.gr.dart';
import 'package:apple_id_auth/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// [AuthScreen] - экран аутентификации.
@RoutePage()
class AuthScreen extends StatelessWidget {
  /// Создает [AuthScreen] с заголовком.
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) => switch (state) {
        SuccessState _ => context.navigateTo(const MainRoute()),
        _ => null,
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Auth'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const SignInWithAppleEvent()),
                child: const Text('Sign in with Apple'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
