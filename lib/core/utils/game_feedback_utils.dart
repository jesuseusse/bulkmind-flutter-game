import 'package:bulkmind/core/models/record.dart';
import 'package:bulkmind/core/utils/time_utils.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

/// Builds the localized title and message shown when a game session ends.
({String title, String message}) buildGameOverFeedback({
  required bool isTimeout,
  required AppLocalizations localizations,
  required Duration totalElapsedTime,
  required int currentLevel,
  required Record record,
  required bool hasNewRecord,
}) {
  final String title = isTimeout
      ? '⏰ ${localizations.timeOut}'
      : '❌ ${localizations.incorrect}';
  final Duration elapsedDuration = Duration(
    milliseconds: totalElapsedTime.inMilliseconds,
  );
  final String totalElapsedLabel = formatDuration(elapsedDuration);
  final String recordTimeLabel = record.bestTime > 0
      ? formatDuration(Duration(milliseconds: record.bestTime))
      : '';

  final StringBuffer recordMessage = StringBuffer()
    ..writeln(
      '${localizations.yourScore}: $currentLevel ${localizations.levels}',
    )
    ..writeln('${localizations.timeTaken}: $totalElapsedLabel')
    ..writeln();

  if (hasNewRecord) {
    recordMessage.writeln(
      '🎉 ${localizations.newRecord}: ${record.maxLevel} ${localizations.levels}',
    );
    if (record.bestTime > 0) {
      recordMessage.write('⏱️ ${localizations.newBestTime}: $recordTimeLabel');
    }
  } else {
    recordMessage.writeln(
      '${localizations.maxLevel}: ${record.maxLevel} ${localizations.levels}',
    );
    if (record.bestTime > 0) {
      recordMessage.write('⏱️ ${localizations.bestTime}: $recordTimeLabel');
    }
  }

  return (title: title, message: recordMessage.toString());
}
