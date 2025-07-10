import 'package:mind_builder/l10n/app_localizations.dart';

String getColorName(String key, AppLocalizations loc) {
  // Use a Map for O(1) lookup instead of a switch for potentially many cases
  // This is slightly more performant and cleaner for a large number of cases.
  final Map<String, String Function()> colorNameMap = {
    'red': () => loc.red,
    'blue': () => loc.blue,
    'green': () => loc.green,
    'yellow': () => loc.yellow,
    'orange': () => loc.orange,
    'purple': () => loc.purple,
    'pink': () => loc.pink,
    'grey': () => loc.grey,
    'brown': () => loc.brown,
    'white': () => loc.white,
    // Add more colors here as needed
  };

  return colorNameMap[key]?.call() ??
      key; // Call the function to get the localized string
}
