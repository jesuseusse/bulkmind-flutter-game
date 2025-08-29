import 'package:go_router/go_router.dart';
import 'package:bulkmind/features/intuition/presentation/intuition_screen.dart';
import 'package:bulkmind/features/logic/presentation/logic_screen.dart';
import 'package:bulkmind/features/patterns/presentation/patterns_screen.dart';
import 'package:bulkmind/features/spatial/presentation/spatial_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

/// This is a placeholder for your actual user authentication check.
/// For example, with Firebase Auth, you would check if FirebaseAuth.instance.currentUser is not null.
bool isUserLoggedIn() {
  // Replace this logic with your actual user verification.
  // For this example, it returns false to demonstrate the redirect to the login screen.
  return false;
}

Future<GoRouter> createAppRouter() async {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
    ],
    redirect: (context, state) {
      // List of routes that do not require authentication.
      final publicRoutes = ['/login', '/onboarding'];

      // Check if the user is logged in.
      final bool isLoggedIn = isUserLoggedIn();

      // If the user is not logged in AND the route they are trying to access
      // is not a public route, redirect them to the login screen.
      if (!isLoggedIn && !publicRoutes.contains(state.uri.toString())) {
        return '/login';
      }

      // If the user is logged in and tries to go to a public route like login or onboarding,
      // redirect them to the main screen.
      if (isLoggedIn && publicRoutes.contains(state.uri.toString())) {
        return '/';
      }

      // If no redirection is needed, return null.
      return null;
    },
  );
}
