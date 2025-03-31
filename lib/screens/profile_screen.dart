import 'package:fluter/providers/activity_provider.dart';
import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
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
    return Consumer2<UserProvider, ThemeProvider>(
      builder: (context, userProvider, themeProvider, child) {
        final user = userProvider.user;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Profile',
              style: GoogleFonts.itim(
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.appBarColor,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
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
                        themeProvider.appBarColor,
                        themeProvider.appBarColor.withOpacity(0.8),
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
                          color: themeProvider.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.textColor,
                        ),
                      ),
                      if (user.bio != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.textColor.withOpacity(0.9),
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
                          color: themeProvider.textColor,
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
                                  context.read<ThemeProvider>().setTheme('Original');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.appBarColor,
                                  foregroundColor: themeProvider.textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Original',
                                  style: GoogleFonts.itim(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<ThemeProvider>().setTheme('Bubble');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.appBarColor,
                                  foregroundColor: themeProvider.textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Bubble',
                                  style: GoogleFonts.itim(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<ThemeProvider>().setTheme('Starry Night');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.appBarColor,
                                  foregroundColor: themeProvider.textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Starry Night',
                                  style: GoogleFonts.itim(),
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
                        style: GoogleFonts.itim(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Consumer<ActivityProvider>(
                        builder: (context, activityProvider, child) {
                          final activities = activityProvider.recentActivities;
                          if (activities.isEmpty) {
                            return Text(
                              'Aucune activité récente.',
                              style: TextStyle(color: themeProvider.textColor),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return ListTile(
                                leading: Icon(Icons.history, color: themeProvider.textColor),
                                title: Text(
                                  activity.displayText,
                                  style: TextStyle(color: themeProvider.textColor),
                                ),
                                subtitle: Text(
                                  '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year} à ${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
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
          ),
          bottomNavigationBar: const BottomNavBar(),
        );
      },
    );
  }
}
