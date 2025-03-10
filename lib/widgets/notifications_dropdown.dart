import 'package:flutter/material.dart';
import 'package:fluter/models/notification.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:provider/provider.dart';

class NotificationsDropdown extends StatelessWidget {
  const NotificationsDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        final recentNotifications = notificationProvider.getRecentNotifications();

        return PopupMenuButton<dynamic>(
          icon: Badge(
            label: Text(unreadCount.toString()),
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          offset: const Offset(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          itemBuilder: (context) {
            if (recentNotifications.isEmpty) {
              return [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Aucune notification'),
                ),
              ];
            }

            return [
              if (unreadCount > 0)
                PopupMenuItem(
                  child: ListTile(
                    title: const Text('Tout marquer comme lu'),
                    trailing: const Icon(Icons.done_all),
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      await notificationProvider.markAllAsRead();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Notifications récentes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ...recentNotifications.map((notification) {
                final icon = _getNotificationIcon(notification.type);
                return PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      icon,
                      color: notification.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        color: notification.isRead ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(notification.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () async {
                      await notificationProvider.markAsRead(notification.id);
                      if (!context.mounted) return;
                      
                      if (notification.boardId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListsScreen(
                              boardId: notification.boardId!,
                              boardName: notification.boardName ?? 'Board',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ];
          },
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.boardShared:
        return Icons.share;
      case NotificationType.cardAssigned:
        return Icons.assignment_ind;
      case NotificationType.dueDate:
        return Icons.access_time;
      case NotificationType.other:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
} 