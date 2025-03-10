import 'package:flutter/material.dart';
import 'package:fluter/models/notification.dart';
import 'package:fluter/services/trello_service.dart';

class NotificationProvider with ChangeNotifier {
  NotificationProvider({required TrelloService trelloService}) 
    : _trelloService = trelloService;

  final TrelloService _trelloService;
  List<TrelloNotification> _notifications = [];

  /// Obtenir toutes les notifications
  List<TrelloNotification> get notifications => _notifications;

  /// Obtenir le nombre de notifications non lues
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Obtenir les notifications récentes
  List<TrelloNotification> getRecentNotifications({int limit = 4}) {
    final sortedNotifications = List<TrelloNotification>.from(_notifications)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedNotifications.take(limit).toList();
  }

  /// Charger les notifications
  Future<void> fetchNotifications() async {
    try {
      _notifications = await _trelloService.getNotifications();
      notifyListeners();
    } catch (error) {
      throw Exception('Erreur lors de la récupération des notifications : $error');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _trelloService.markNotificationAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = TrelloNotification(
            id: _notifications[index].id,
            type: _notifications[index].type,
            message: _notifications[index].message,
            date: _notifications[index].date,
            isRead: true,
            boardId: _notifications[index].boardId,
            boardName: _notifications[index].boardName,
          );
          notifyListeners();
        }
      }
    } catch (error) {
      throw Exception('Erreur lors du marquage de la notification comme lue : $error');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final success = await _trelloService.markAllNotificationsAsRead();
      if (success) {
        _notifications = _notifications.map((notification) => TrelloNotification(
          id: notification.id,
          type: notification.type,
          message: notification.message,
          date: notification.date,
          isRead: true,
          boardId: notification.boardId,
          boardName: notification.boardName,
        )).toList();
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Erreur lors du marquage de toutes les notifications comme lues : $error');
    }
  }
} 