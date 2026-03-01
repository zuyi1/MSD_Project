class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;

  UserProfile({required this.name, required this.age, required this.weight, required this.height});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String,
      age: map['age'] as int,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }

  double calculateBMI() {
    if (height == 0) return 0;
    // Height in meters for BMI calculation
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}
