class FoodItem {
  final int? id;
  final String name;
  final double calories;
  final String description;

  FoodItem({this.id, required this.name, required this.calories, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'description': description,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      description: map['description'] as String? ?? 'A healthy and delicious choice.',
    );
  }
}
