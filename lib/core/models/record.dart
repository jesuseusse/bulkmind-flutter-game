class Record {
  final int maxLevel;
  final int bestTime;

  const Record({required this.maxLevel, required this.bestTime});

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      maxLevel: map['maxLevel'] as int,
      bestTime: map['bestTime'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'maxLevel': maxLevel, 'bestTime': bestTime};
  }
}
