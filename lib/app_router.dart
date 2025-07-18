import 'package:go_router/go_router.dart';
import 'package:mind_builder/features/intuition/presentation/intuition_screen.dart';
import 'package:mind_builder/features/logic/presentation/logic_screen.dart';
import 'package:mind_builder/features/memory/presentation/memory_screen.dart';
import 'package:mind_builder/features/spatial/presentation/spatial_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'core/services/launch_service.dart';

Future<GoRouter> createAppRouter() async {
  final showOnboarding = await LaunchService.shouldShowOnboarding();

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
        path: '/memory',
        builder: (context, state) => const MemoryScreen(),
      ),
      GoRoute(
        path: '/spatial',
        builder: (context, state) => const SpatialScreen(),
      ),
    ],
  );
}
