import 'package:fluter/providers/activity_provider.dart';
import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/providers/user_provider.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:fluter/widgets/favorites_carousel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les informations utilisateur, les favoris et les activités récentes au démarrage
    Future.microtask(() async {
      // ignore: use_build_context_synchronously
      await context.read<UserProvider>().loadUserInfo();
      // ignore: use_build_context_synchronously
      await context.read<FavoritesProvider>().loadFavorites();
      // ignore: use_build_context_synchronously
      await context.read<ActivityProvider>().loadRecentActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        // ignore: deprecated_member_use
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hi, ${user.fullName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(user.avatarUrl),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (user.bio != null)
                                  Text(
                                    user.bio!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const FavoritesCarousel(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activités récentes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Consumer<ActivityProvider>(
                        builder: (context, activityProvider, child) {
                          final activities = activityProvider.recentActivities; // Utilise les 5 plus récentes
                          if (activities.isEmpty) {
                            return const Text('Aucune activité récente.');
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(activity.displayText),
                                subtitle: Text(
                                  '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year} à ${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}',
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
