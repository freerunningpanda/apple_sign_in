import 'package:apple_id_auth/core/presentation/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// [AuthScreen] - экран аутентификации.
@RoutePage()
class AuthScreen extends StatelessWidget {
  /// Создает [AuthScreen] с заголовком.
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Auth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.pushRoute(const MainRoute()),
              child: const Text('Sign in with Apple'),
            ),
          ],
        ),
      ),
    );
  }
}
