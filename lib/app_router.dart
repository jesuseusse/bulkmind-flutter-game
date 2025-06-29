import 'package:go_router/go_router.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'core/services/launch_service.dart';

Future<GoRouter> createAppRouter() async {
  final showOnboarding = await LaunchService.shouldShowOnboarding();

  return GoRouter(
    initialLocation: true ? '/onboarding' : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
