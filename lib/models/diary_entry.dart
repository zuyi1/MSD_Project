class DiaryEntry {
  final int? id;
  final String imagePath;
  final String comment;
  final DateTime dateTime;
  final double calories;

  DiaryEntry({
    this.id, 
    required this.imagePath, 
    required this.comment, 
    required this.dateTime,
    this.calories = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'comment': comment,
      'dateTime': dateTime.toIso8601String(),
      'calories': calories,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      imagePath: map['imagePath'],
      comment: map['comment'],
      dateTime: DateTime.parse(map['dateTime']),
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
