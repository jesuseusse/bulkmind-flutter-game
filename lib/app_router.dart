import 'package:bulkmind/features/auth/presentation/pages/signup_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/features/intuition/presentation/intuition_screen.dart';
import 'package:bulkmind/features/logic/presentation/logic_screen.dart';
import 'package:bulkmind/features/patterns/presentation/patterns_screen.dart';
import 'package:bulkmind/features/spatial/presentation/spatial_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'features/profile/presentation/profile_screen.dart';

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
    ],
    redirect: (context, state) {
      // List of routes that do not require authentication.
      final publicRoutes = ['/login', '/onboarding', '/sign-up'];

      // Check if the user is logged in.
      final bool loggedIn = isLoggedIn();

      // If the user is not logged in AND the route they are trying to access
      // is not a public route, redirect them to the login screen.
      final path = state.uri.path;
      if (!loggedIn && !publicRoutes.contains(path)) {
        return '/login';
      }

      // If the user is logged in and tries to go to a public route like login or onboarding,
      // redirect them to the main screen.
      if (loggedIn && publicRoutes.contains(path)) {
        return '/';
      }

      // If no redirection is needed, return null.
      return null;
    },
  );
}
