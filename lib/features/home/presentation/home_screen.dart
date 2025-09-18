import 'package:bulkmind/features/auth/domain/user_model.dart' as domain;
import 'package:bulkmind/features/paywall/presentation/get_all_games_screen.dart';
import 'package:bulkmind/features/user/data/user_repository_firestore.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = "/";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = firebase_auth.FirebaseAuth.instance;
    final current = auth.currentUser;
    final repo = FirestoreUserRepository();

    Widget buildContent(bool hasFullAccess) => _HomeContent(
      l10n: l10n,
      hasFullAccess: hasFullAccess,
      onOpenAllGames: () => context.go(GetAllGamesScreen.routeName),
      onNavigate: (route) => context.go(route),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: current == null
          ? buildContent(false)
          : FutureBuilder<domain.User?>(
              future: repo.getUser(current.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return buildContent(false);
                }
                final user = snapshot.data;
                final hasFullAccess = user?.isSubscribed ?? false;
                return buildContent(hasFullAccess);
              },
            ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final AppLocalizations l10n;
  final bool hasFullAccess;
  final VoidCallback onOpenAllGames;
  final ValueChanged<String> onNavigate;

  const _HomeContent({
    required this.l10n,
    required this.hasFullAccess,
    required this.onOpenAllGames,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final games = _gameEntries(l10n);
    if (!hasFullAccess) {
      final firstGame = games.first;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              _GameCard(
                title: firstGame.title,
                icon: firstGame.icon,
                onTap: () => onNavigate(firstGame.route),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onOpenAllGames,
                  child: Text(l10n.getAllGamesTitle),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (final game in games)
              _GameCard(
                title: game.title,
                icon: game.icon,
                onTap: () => onNavigate(game.route),
              ),
          ],
        ),
      ),
    );
  }

  List<_GameEntry> _gameEntries(AppLocalizations l10n) {
    return [
      _GameEntry(title: l10n.logic, icon: Icons.calculate, route: '/logic'),
      _GameEntry(
        title: l10n.intuition,
        icon: Icons.lightbulb_outline,
        route: '/intuition',
      ),
      _GameEntry(
        title: l10n.patterns,
        icon: Icons.extension,
        route: '/patterns',
      ),
      _GameEntry(title: l10n.spatial, icon: Icons.grid_view, route: '/spatial'),
    ];
  }
}

class _GameEntry {
  final String title;
  final IconData icon;
  final String route;

  const _GameEntry({
    required this.title,
    required this.icon,
    required this.route,
  });
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
