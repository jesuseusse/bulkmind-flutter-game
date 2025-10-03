import 'package:flutter/widgets.dart';

class ColorGameData {
  final String wordKey;
  final Color displayedColor;
  final List<Color> options;
  final Duration? timeLimit;

  ColorGameData({
    required this.wordKey,
    required this.displayedColor,
    required this.options,
    this.timeLimit,
  });

  ColorGameData copyWith({
    String? wordKey,
    Color? displayedColor,
    List<Color>? options,
    Duration? timeLimit,
  }) {
    return ColorGameData(
      wordKey: wordKey ?? this.wordKey,
      displayedColor: displayedColor ?? this.displayedColor,
      options: options ?? this.options,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  @override
  String toString() {
    return 'ColorGameData(wordKey: $wordKey, displayedColor: $displayedColor, options: $options)';
  }
}
