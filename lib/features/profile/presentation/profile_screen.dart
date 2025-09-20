import 'package:bulkmind/features/user/data/user_repository_firestore.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = FirebaseAuth.instance;
    final current = auth.currentUser;

    if (current == null) {
      // Should be redirected by router, but handle gracefully.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appName), centerTitle: true),
        body: Center(child: Text(l10n.signIn)),
      );
    }

    final repo = FirestoreUserRepository();
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile), centerTitle: true),
      body: StreamBuilder(
        stream: repo.watchById(current.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            );
          }
          final formattedBirthday = DateFormat.yMMMd(
            locale,
          ).format(user.birthday);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.fullName),
                  subtitle: Text(user.fullName),
                ),
                ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: Text(l10n.birthday),
                  subtitle: Text(formattedBirthday),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.email),
                  subtitle: Text(user.email),
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.goToHome),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version;
                    if (version == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'v $version',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
