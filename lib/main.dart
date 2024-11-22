import 'package:apple_id_auth/app.dart';
import 'package:apple_id_auth/core/di/injection_container.dart';
import 'package:apple_id_auth/core/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  /// Инициализация Flutter.
  /// Проверка на инициализацию FlutterBinding.
  WidgetsFlutterBinding.ensureInitialized();

  /// Инициализация зависимостей.
  await dependencyInjectionInit();

  final router = sl<AppRouter>();

  runApp(App(router: router));
}
