class FoodItem {
  final int? id;
  final String name;
  final double calories;

  FoodItem({this.id, required this.name, required this.calories});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
    );
  }
}
