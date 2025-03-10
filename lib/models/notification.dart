/// Représente une notification dans l'application
class TrelloNotification {
  /// Crée une nouvelle instance de [TrelloNotification]
  TrelloNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.date,
    required this.isRead,
    this.boardId,
    this.boardName,
  });

  /// Crée une [TrelloNotification] à partir d'un objet JSON
  factory TrelloNotification.fromJson(Map<String, dynamic> json) {
    return TrelloNotification(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => NotificationType.other,
      ),
      message: json['message'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
      boardId: json['boardId'],
      boardName: json['boardName'],
    );
  }

  /// L'identifiant unique de la notification
  final String id;

  /// Le type de notification
  final NotificationType type;

  /// Le message de la notification
  final String message;

  /// La date de la notification
  final DateTime date;

  /// Si la notification a été lue
  final bool isRead;

  /// L'identifiant du board concerné (optionnel)
  final String? boardId;

  /// Le nom du board concerné (optionnel)
  final String? boardName;

  /// Convertit la notification en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
      if (boardId != null) 'boardId': boardId,
      if (boardName != null) 'boardName': boardName,
    };
  }
}

/// Les différents types de notifications possibles
enum NotificationType {
  /// Quelqu'un vous a mentionné
  mention,

  /// Un board a été partagé avec vous
  boardShared,

  /// Une carte a été assignée
  cardAssigned,

  /// Une date limite approche
  dueDate,

  /// Autre type de notification
  other,
} 
