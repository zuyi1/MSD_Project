class WaterLog {
  final int? id;
  final double amount; // in ml
  final DateTime dateTime;

  WaterLog({this.id, required this.amount, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
