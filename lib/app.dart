import 'package:apple_id_auth/core/di/injection_container.dart';
import 'package:apple_id_auth/core/presentation/router/app_router.dart';
import 'package:apple_id_auth/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// [App] - главный виджет приложения.
class App extends StatelessWidget {
  /// Создает [App].
  const App({
    required this.router,
    super.key,
  });

  /// Роутер приложения.
  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: router.config(),
      ),
    );
  }
}
