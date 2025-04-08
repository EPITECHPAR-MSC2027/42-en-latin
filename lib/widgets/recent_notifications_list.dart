import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecentNotificationsList extends StatelessWidget {
  const RecentNotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationProvider, ThemeProvider>(
      builder: (context, notificationProvider, themeProvider, child) {
        final recentNotifications = notificationProvider.getRecentNotifications();

        if (recentNotifications.isEmpty) {
          return Center(
            child: Text(
              'No recent notification',
              style: TextStyle(
                // ignore: deprecated_member_use
                color: themeProvider.vertText.withOpacity(0.5),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Latest notifications',
                style: GoogleFonts.itim(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.vertText,
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
                  color: themeProvider.bleuClair,
                  child: ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification.type),
                      color: notification.isRead ? themeProvider.grisClair : themeProvider.vertGris,
                    ),
                    title: Text(
                      notification.message,
                      style: GoogleFonts.itim(
                        color: notification.isRead ? themeProvider.grisClair : themeProvider.vertText,
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(notification.date),
                      style: TextStyle(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: themeProvider.vertText.withOpacity(0.7),
                      ),
                    ),
                    onTap: () async {
                      await notificationProvider.markAsRead(notification.id);
                      if (!context.mounted) return;
                      
                      if (notification.boardId != null) {
                        await Provider.of<BoardsProvider>(context, listen: false)
                            .markBoardAsOpened(notification.boardId!);
                        await Navigator.push(
                          // ignore: use_build_context_synchronously
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
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Now';
    }
  }
}
