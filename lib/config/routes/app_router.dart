import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/pages/analysis_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/health_dashboard/presentation/pages/dashboard_page.dart';
import '../../features/health_dashboard/presentation/pages/metric_detail_page.dart';
import '../../features/recipes/presentation/pages/recipes_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
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

      // ---------------------------------------------------------
      // 1. HANDLING LOADING
      // ---------------------------------------------------------
      // If we are just starting up (Initial) or actively Loading,
      // stay on the Splash screen to prevent flashing.
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final bool isLoggedIn = authState is Authenticated;

      // ---------------------------------------------------------
      // 2. UNAUTHENTICATED USERS
      // ---------------------------------------------------------
      if (!isLoggedIn) {
        if (isSplash) {
          return RoutePaths.welcome;
        }

        // If strictly on Login/Register/Welcome, let them stay there.
        if (isLoggingIn || isWelcome) {
          return null;
        }

        // If they try to access a protected route (like /home), kick them to Login.
        return RoutePaths.login;
      }

      // ---------------------------------------------------------
      // 3. AUTHENTICATED USERS
      // ---------------------------------------------------------
      if (isLoggedIn) {
        // If they are on an Auth screen (Splash/Login/Welcome), send them Home.
        if (isLoggingIn || isSplash || isWelcome) {
          return RoutePaths.home;
        }

        // Otherwise, let them proceed (e.g., to /recipes).
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

      // --- SHELL ROUTE ---
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
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getCurrentIndex(),
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
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Recipes',
          ),
        ],
      ),
    );
  }
}
