import 'package:e_mon_app/core/routes/app_routes.dart';
import 'package:e_mon_app/features/home/presentation/views/home_view.dart';
import 'package:go_router/go_router.dart';

class RouterGenerator {
  static GoRouter mainRouting = GoRouter(
    initialLocation: AppRoutes.homeView,
    // errorBuilder: (context, state) {
      // return UnKnownRouteView();
    // },
    routes: [
      GoRoute(
        name: AppRoutes.homeView,
        path: AppRoutes.homeView,
        builder: (context, state) => HomeView(),
      ),
    ],
  );
}
