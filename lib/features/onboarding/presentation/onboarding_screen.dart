import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/launch_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    await LaunchService.markOnboardingSeen();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bienvenido a Mental Gym',
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _finishOnboarding(context),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
