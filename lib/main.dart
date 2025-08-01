import 'package:flutter/foundation.dart';
import 'core/database/game_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset the database only in debug mode
  if (kDebugMode) {
    final db = GameDataBase();
    await db.resetDatabase();
  }

  final router = await createAppRouter();
  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Mind Builder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('es')],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'es') {
          return const Locale('es');
        }
        return const Locale('en');
      },
    );
  }
}
