class Activity {
  final String id;
  final String type;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
} 