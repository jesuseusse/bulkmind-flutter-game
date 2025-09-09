import 'package:bulkmind/features/paywall/presentation/get_all_games_screen.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              _GameCard(
                title: AppLocalizations.of(context)!.logic,
                icon: Icons.calculate,
                onTap: () => context.go('/logic'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(GetAllGamesScreen.routeName),
                  child: Text(AppLocalizations.of(context)!.getAllGamesTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).colorScheme.surface;
    return InkWell(
      onTap: () {
        onTap();
      },
      child: SizedBox(
        width: 150,
        height: 150,
        child: Card(
          color: Theme.of(context).colorScheme.inverseSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: textColor),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
