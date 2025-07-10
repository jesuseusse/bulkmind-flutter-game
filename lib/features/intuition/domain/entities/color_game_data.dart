import 'package:flutter/widgets.dart';

class ColorGameData {
  final String wordKey;
  final Color displayedColor;
  final List<Color> options;

  ColorGameData({
    required this.wordKey,
    required this.displayedColor,
    required this.options,
  });

  ColorGameData copyWith({
    String? wordKey,
    Color? displayedColor,
    List<Color>? options,
  }) {
    return ColorGameData(
      wordKey: wordKey ?? this.wordKey,
      displayedColor: displayedColor ?? this.displayedColor,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return 'ColorGameData(wordKey: $wordKey, displayedColor: $displayedColor, options: $options)';
  }
}
