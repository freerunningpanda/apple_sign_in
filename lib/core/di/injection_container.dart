import 'package:apple_id_auth/core/presentation/router/app_router.dart';
import 'package:apple_id_auth/core/utils/api_keys.dart';
import 'package:apple_id_auth/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apple_id_auth/features/auth/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:apple_id_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:apple_id_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:apple_id_auth/features/auth/domain/usecases/sign_in_with_apple_use_case.dart';
import 'package:apple_id_auth/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// [GetIt] - это сервис-локатор.
final sl = GetIt.instance;
late final FlutterSecureStorage _secureStorage;
late final Dio _dio;

/// Инициализация зависимостей.
Future<void> dependencyInjectionInit() async {
  _dio = Dio(
    BaseOptions(
      baseUrl: ApiKeys.host,
    ),
  );

  _secureStorage = const FlutterSecureStorage();

  sl
    // Утилиты.
    ..registerLazySingleton<Dio>(() => _dio)
    ..registerLazySingleton<FlutterSecureStorage>(() => _secureStorage);

  // Инициализация зависимостей авторизации.
  _initAuth();

  // Инициализация роутера.
  _initRouter();
}

void _initAuth() {
  sl
    // Блок.
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(sl()))

    // Сценарии.
    ..registerLazySingleton<SignInWithAppleUseCase>(
      () => SignInWithAppleUseCase(sl()),
    )

    // Репозиторий.
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))

    // Источник данных.
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(sl(), sl()),
    );
}

void _initRouter() {
  sl.registerLazySingleton<AppRouter>(AppRouter.new);
}
