import 'package:flutter/material.dart';
import 'package:fluter/models/notification.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:provider/provider.dart';

class RecentNotificationsList extends StatelessWidget {
  const RecentNotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final recentNotifications = notificationProvider.getRecentNotifications();

        if (recentNotifications.isEmpty) {
          return const Center(
            child: Text('Aucune notification récente'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Notifications récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentNotifications.length,
              itemBuilder: (context, index) {
                final notification = recentNotifications[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification.type),
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
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    if (type.contains('mention')) {
      return Icons.alternate_email;
    } else if (type.contains('added') || type.contains('make')) {
      return Icons.person_add;
    } else if (type.contains('Card')) {
      return Icons.assignment;
    } else if (type.contains('due')) {
      return Icons.access_time;
    } else if (type.contains('comment')) {
      return Icons.comment;
    } else if (type.contains('attachment')) {
      return Icons.attach_file;
    } else {
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