import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_drawer.dart';
import '../../features/analysis/presentation/pages/analysis_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/health_details_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/health_dashboard/presentation/pages/dashboard_page.dart';
import '../../features/health_dashboard/presentation/pages/metric_detail_page.dart';
import '../../features/recipes/domain/entities/recipe.dart';
import '../../features/recipes/presentation/pages/recipe_detail_page.dart';
import '../../features/recipes/presentation/pages/recipes_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../injection_container.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final AuthBloc _authBloc = sl<AuthBloc>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,

    refreshListenable: GoRouterRefreshStream(_authBloc.stream),

    redirect: (context, state) {
      final authState = _authBloc.state;
      final String location = state.uri.toString();

      final bool isLoggingIn =
          location == RoutePaths.login || location == RoutePaths.register;
      final bool isSplash = location == RoutePaths.splash;
      final bool isWelcome = location == RoutePaths.welcome;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final bool isLoggedIn = authState is Authenticated;

      if (!isLoggedIn) {
        if (isSplash) {
          return RoutePaths.welcome;
        }

        if (isLoggingIn || isWelcome) {
          return null;
        }

        return RoutePaths.login;
      }

      if (isLoggedIn) {
        if (isLoggingIn || isSplash || isWelcome) {
          return RoutePaths.home;
        }

        return null;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.healthDetails,
        name: RouteNames.healthDetails,
        builder: (context, state) => const HealthDetailsPage(),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainWrapperPage(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const DashboardPage(),
            routes: [
              GoRoute(
                path: RoutePaths.metricDetail,
                name: RouteNames.metricDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const MetricDetailPage(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.analysis,
            name: RouteNames.analysis,
            builder: (context, state) => const AnalysisPage(),
          ),
          GoRoute(
            path: RoutePaths.recipes,
            name: RouteNames.recipes,
            builder: (context, state) => const RecipesPage(),
          ),
          GoRoute(
            path: RoutePaths.reports,
            name: RouteNames.reports,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.recipeDetail,
        name: RouteNames.recipeDetail,
        builder: (context, state) {
          final recipe = state.extra as Recipe;
          return RecipeDetailPage(recipe: recipe);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MainWrapperPage extends StatelessWidget {
  final Widget child;

  const MainWrapperPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    int getCurrentIndex() {
      final String location = GoRouterState.of(context).uri.toString();
      if (location.startsWith(RoutePaths.analysis)) return 1;
      if (location.startsWith(RoutePaths.recipes)) return 2;
      if (location.startsWith(RoutePaths.reports)) return 3;
      if (location.startsWith(RoutePaths.settings)) return 4;
      return 0;
    }

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHighContrast = settings.highContrast;

        final Color bgColor = isHighContrast ? Colors.black : Colors.white;
        final Color selectedColor = isHighContrast
            ? Colors.yellowAccent
            : const Color(0xFF2563EB);
        final Color unselectedColor = isHighContrast
            ? Colors.white
            : Colors.grey.shade400;
        final Color borderColor = isHighContrast
            ? Colors.white
            : Colors.grey.shade200;

        return Scaffold(
          drawer: const AppDrawer(),
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: isHighContrast ? 2 : 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: getCurrentIndex(),
              type: BottomNavigationBarType.fixed,
              backgroundColor: bgColor,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,

              selectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              elevation: 0,

              onTap: (index) {
                switch (index) {
                  case 0:
                    context.goNamed(RouteNames.home);
                    break;
                  case 1:
                    context.goNamed(RouteNames.analysis);
                    break;
                  case 2:
                    context.goNamed(RouteNames.recipes);
                    break;
                  case 3:
                    context.goNamed(RouteNames.reports);
                    break;
                  case 4:
                    context.goNamed(RouteNames.settings);
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Analysis',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Recipes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
