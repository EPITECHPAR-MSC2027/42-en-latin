class Activity {
  final String id;
  final String type;
  final DateTime timestamp;
  final String? text;
  final Map<String, dynamic>? data;

  Activity({
    required this.id,
    required this.type,
    required this.timestamp,
    this.text,
    this.data,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['date'] as String),
      text: json['text'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  String get displayText {
    // If there's a text property, use it
    if (text != null && text!.isNotEmpty) {
      return text!;
    }
    
    // Otherwise, create a readable message based on activity type
    String message = 'Activity of type: $type';
    
    if (data != null) {
      // Add board name if available
      if (data!.containsKey('board') && data!['board'] is Map<String, dynamic>) {
        message += ' on board "${data!['board']['name']}"';
      }
      
      // Add card name if available
      if (data!.containsKey('card') && data!['card'] is Map<String, dynamic>) {
        message += ' - card "${data!['card']['name']}"';
      }
    }
    
    return message;
  }
}