import 'dart:math';

class LevelData {
  final List<int> gridSize;
  final List<List<bool>> pattern;
  final double maxTime;

  LevelData({
    required this.gridSize,
    required this.pattern,
    required this.maxTime,
  });
}

/// Generates a memory pattern in a grid of rows x columns.
/// The grid contains `true` values (active cells to memorize) and `false` values (empty cells).
/// The number of active cells does not exceed 80% of the total grid.
List<List<bool>> generateMemoryPattern(int rows, int columns) {
  final random = Random(); // Create Random instance to generate random values

  final totalCells =
      rows * columns; // Calculate the total number of cells in the grid
  final maxActiveCells = (totalCells * 0.8)
      .floor(); // Calculate 80% of the cells as the maximum active cells

  int activeCells = 0; // Counter of active cells generated so far

  // Initialize the grid as a list of lists with false values
  List<List<bool>> grid = List.generate(
    rows,
    (_) => List.generate(columns, (_) => false),
  );

  // Iterate over each row and column of the grid
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < columns; col++) {
      // If the maximum number of active cells has not yet been reached
      if (activeCells < maxActiveCells) {
        // Generate a random boolean to decide whether to activate the cell
        bool shouldActivate = random.nextBool();

        if (shouldActivate) {
          grid[row][col] = true; // Mark the cell as active
          activeCells++; // Increment the active cells counter
        }
      }
    }
  }

  return grid; // Return the generated grid
}
// example
// [
//   [true, false, true, false],
//   [false, true, false, true],
//   [true, false, false, false],
// ]

List<int> generateGridSize(int level) {
  // Base size starts at 2x2 for level 0
  int rows = 2;
  int columns = 2;

  // Increase rows and columns as the level goes up
  // For every 4 levels, increase the number of columns
  // For every 3 levels, increase the number of rows
  rows += (level ~/ 4);
  columns += (level ~/ 4);

  // Cap the maximum grid size at 6 rows x 8 columns
  if (rows > 8) rows = 8;
  if (columns > 8) columns = 8;

  return [rows, columns];
}

double generateMaxTimeInSeconds(int level) {
  // Keep 6 seconds until level 10
  if (level <= 10) {
    return 6;
  }

  // After level 10, decrease linearly to reach 2 seconds at level 20
  int extraLevel = level - 10;
  double time = 6 - (extraLevel * 0.4);

  // Ensure the minimum time does not drop below 2 seconds
  if (time < 2) time = 2;

  return time;
}

LevelData generateLevel(int level, List<List<bool>> previousPattern) {
  List<int> gridSize = generateGridSize(level);
  int rows = gridSize[0];
  int columns = gridSize[1];

  List<List<bool>> pattern;
  do {
    pattern = generateMemoryPattern(rows, columns);
  } while (_arePatternsEqual(pattern, previousPattern));

  double maxTime = generateMaxTimeInSeconds(level);

  return LevelData(gridSize: gridSize, pattern: pattern, maxTime: maxTime);
}

/// Helper to compare two patterns for equality
bool _arePatternsEqual(List<List<bool>> a, List<List<bool>> b) {
  if (a.isEmpty || b.isEmpty || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].length != b[i].length) return false;
    for (int j = 0; j < a[i].length; j++) {
      if (a[i][j] != b[i][j]) return false;
    }
  }
  return true;
}
