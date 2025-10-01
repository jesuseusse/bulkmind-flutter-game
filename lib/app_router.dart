import 'package:bulkmind/features/auth/presentation/pages/signup_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/features/intuition/presentation/intuition_screen.dart';
import 'package:bulkmind/features/logic/presentation/logic_screen.dart';
import 'package:bulkmind/features/patterns/presentation/patterns_screen.dart';
import 'package:bulkmind/features/spatial/presentation/spatial_screen.dart';
import 'package:bulkmind/features/auth/presentation/pages/check_email_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'features/profile/presentation/profile_screen.dart';
import 'features/paywall/presentation/get_all_games_screen.dart';

/// Simple ChangeNotifier that notifies GoRouter on auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Future<GoRouter> createAppRouter() async {
  final auth = firebase_auth.FirebaseAuth.instance;
  bool isLoggedIn() => auth.currentUser != null;

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: CheckEmailScreen.routeName,
        builder: (context, state) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/logic', builder: (context, state) => const LogicScreen()),
      GoRoute(
        path: '/intuition',
        builder: (context, state) => const IntuitionScreen(),
      ),
      GoRoute(
        path: '/patterns',
        builder: (context, state) => const PatternsScreen(),
      ),
      GoRoute(
        path: '/spatial',
        builder: (context, state) => const SpatialScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: GetAllGamesScreen.routeName,
        builder: (context, state) => const GetAllGamesScreen(),
      ),
    ],
    redirect: (context, state) {
      final publicRoutes = ['/', '/login', '/onboarding', '/sign-up'];
      final path = state.uri.path;
      final bool loggedIn = isLoggedIn();
      final bool emailVerified = auth.currentUser?.emailVerified ?? false;

      if (!loggedIn) {
        if (path == CheckEmailScreen.routeName) {
          return '/login';
        }
        if (!publicRoutes.contains(path)) {
          return '/login';
        }
        return null;
      }

      if (!emailVerified && path != CheckEmailScreen.routeName) {
        return CheckEmailScreen.routeName;
      }

      if (emailVerified && path == CheckEmailScreen.routeName) {
        return '/';
      }

      if (emailVerified && publicRoutes.contains(path) && path != '/') {
        return '/';
      }

      return null;
    },
  );
}
