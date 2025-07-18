import 'dart:math';

Map<String, dynamic> generateLogicPuzzle() {
  final random = Random();

  // Generate 4 unique random numbers between 0 and 100
  Set<int> uniqueNumbers = {};
  while (uniqueNumbers.length < 4) {
    uniqueNumbers.add(random.nextInt(101));
  }
  List<int> numbers = uniqueNumbers.toList();

  // chorrse between ascending ('<')  and descending order ('>')
  final bool ascending = random.nextBool();
  final String order = ascending ? '<' : '>';

  // get the sorted list based on the chosen order
  final List<int> sortedNumbers = _sortNumbers(numbers, ascending);

  // shuffle the sorted numbers
  List<int> shuffledNumbers = List.from(sortedNumbers)..shuffle(random);

  return {
    'question': order,
    'options': shuffledNumbers,
    'solution': sortedNumbers,
  };
}

List<int> _sortNumbers(List<int> numbers, bool ascending) {
  final sorted = List<int>.from(numbers)..sort();
  return ascending ? sorted : sorted.reversed.toList();
}
