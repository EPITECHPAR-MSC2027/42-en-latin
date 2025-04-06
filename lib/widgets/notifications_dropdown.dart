import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  child: Text('No notifications'),
                ),
              ];
            }

            return [
              if (unreadCount > 0)
                PopupMenuItem(
                  child: ListTile(
                    title: const Text('Mark all as read'),
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
                  'Recent notifications',
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
                        await Provider.of<BoardsProvider>(context, listen: false)
                            .markBoardAsOpened(notification.boardId!);
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
              }),
            ];
          },
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
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
} 
