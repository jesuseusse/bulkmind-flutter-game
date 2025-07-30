String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  final milliseconds = (duration.inMilliseconds.remainder(1000) / 10)
      .truncate()
      .toString()
      .padLeft(2, '0');

  // Si quieres siempre mostrar HH:mm:ss:ms
  return "$hours:$minutes:$seconds:$milliseconds";
}
