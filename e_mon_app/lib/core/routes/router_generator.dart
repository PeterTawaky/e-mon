import 'package:e_mon_app/core/routes/app_routes.dart';
import 'package:e_mon_app/features/auth/presentation/views/login_view.dart';
import 'package:e_mon_app/features/home/presentation/views/home_view.dart';
import 'package:go_router/go_router.dart';

class RouterGenerator {
  static GoRouter mainRouting = GoRouter(
    initialLocation: AppRoutes.loginView,
    // errorBuilder: (context, state) {
    // return UnKnownRouteView();
    // },
    routes: [
      GoRoute(
        name: AppRoutes.loginView,
        path: AppRoutes.loginView,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        name: AppRoutes.homeView,
        path: AppRoutes.homeView,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
