import 'package:fluter/providers/activity_provider.dart';
import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/providers/user_provider.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:fluter/widgets/favorites_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFFFEDE3),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFC0CCC9),
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
                        'Bonjour, ${user.fullName}',
                        style: GoogleFonts.itim(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (user.bio != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Themes',
                        style: GoogleFonts.itim(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF314A43),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implémenter le changement de thème
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF737C7B),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Original',
                                  style: GoogleFonts.itim(color: Color(0xFFD4F0CC)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implémenter le changement de thème
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5C9CF),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Bubble',
                                  style: GoogleFonts.itim(color: Color(0xFFCF78B5)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implémenter le changement de thème
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3785D8),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Starry Night',
                                  style: GoogleFonts.itim(color: Color(0xFFABC8FF)),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.itim(fontSize: 25, fontWeight: FontWeight.bold, color: const Color(0xFF314A43)),
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
