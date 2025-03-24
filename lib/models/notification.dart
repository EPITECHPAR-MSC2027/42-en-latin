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

  /// L'identifiant unique de la notification
  final String id;

  /// Le type de notification (directement depuis l'API Trello)
  final String type;

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
      'type': type,
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
