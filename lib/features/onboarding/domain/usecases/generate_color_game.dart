import 'dart:math';
import 'package:flutter/material.dart';

final List<String> colorWords = [
  'red',
  'blue',
  'green',
  'yellow',
  'orange',
  'purple',
  'pink',
  'grey',
  'brown',
  'white',
];

final Map<String, Color> colorMap = {
  'red': Colors.red,
  'blue': Colors.blue,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'grey': Colors.grey,
  'brown': Colors.brown,
  'white': Colors.white,
};

final _random = Random();

/// Genera una palabra de color (ej. "ROJO") con un color distinto (ej. texto en azul)
MapEntry<String, Color> generateColorWordPair() {
  final word = colorWords[_random.nextInt(colorWords.length)];

  // Elegir un color distinto al que representa la palabra
  List<String> otherColors = colorWords.where((w) => w != word).toList();
  final displayedColorName = otherColors[_random.nextInt(otherColors.length)];
  final displayedColor = colorMap[displayedColorName]!;

  return MapEntry(word, displayedColor);
}

/// Genera una lista de opciones (colores), incluyendo el color correcto y el color de la palabra
List<Color> generateColorOptions(String wordKey, Color displayedColor) {
  final allColors = colorMap.values.toList();
  final correctColor = displayedColor;
  final wordColor = colorMap[wordKey]!;

  // Crear un conjunto con ambos colores obligatorios
  final requiredColors = {correctColor, wordColor};

  // Filtrar colores que no estén en requiredColors
  final otherColors =
      allColors.where((c) => !requiredColors.contains(c)).toList()..shuffle();

  // Tomar 2 colores incorrectos adicionales
  final options = [...requiredColors, ...otherColors.take(2)];
  options.shuffle();

  return options;
}

class ColorGameData {
  final String wordKey;
  final Color displayedColor;
  final List<Color> options;

  ColorGameData({
    required this.wordKey,
    required this.displayedColor,
    required this.options,
  });
}
