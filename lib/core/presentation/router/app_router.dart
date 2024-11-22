import 'package:apple_id_auth/core/presentation/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Screen|Page,Route',
)

/// [AppRouter] - главный роутер приложения.
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: AuthRoute.page,
        ),
        AutoRoute(
          path: '/main',
          page: MainRoute.page,
        ),
      ];
}
