import 'dart:developer' as developer;

import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/screens/weather_screen.dart';
import 'package:fluter/widgets/board_carousel.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:fluter/widgets/notifications_dropdown.dart';
import 'package:fluter/widgets/recent_notifications_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
/// **Écran d'accueil**
class HomeScreen extends StatefulWidget {
  /// **HomeScreen Constructor**
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

/// **HomeScreen State**
class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log('HomeScreen: initState');
    Future<void>.microtask(() async {
      await _loadData();
      // Load notifications at startup
      // ignore: use_build_context_synchronously
      await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  /// **Load necessary data**
  Future<void> _loadData() async {
    try {
      developer.log('HomeScreen: Loading boards');
      // Load boards for the carousel
      await Provider.of<BoardsProvider>(context, listen: false).fetchBoards();
      developer.log('HomeScreen: Boards loaded');
    } catch (e) {
      developer.log('HomeScreen: Error loading boards: $e');
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.beige,
          appBar: AppBar(
            toolbarHeight: kToolbarHeight,
            title: Text(
              'Home Page',
              style: GoogleFonts.itim(
                color: themeProvider.vertText,
              ),
            ),
            backgroundColor: themeProvider.vertGris,
            actions: const <Widget>[
              WeatherScreen(),
              NotificationsDropdown(),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Welcome Back',
                        style: GoogleFonts.itim(
                          fontSize: 44,
                          color: themeProvider.rouge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Ready to work ?',
                        style: GoogleFonts.itim(
                          fontSize: 20,
                          color: themeProvider.vertText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: themeProvider.vertText,
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Text(
                          'Error: $_errorMessage',
                          style: TextStyle(
                            color: themeProvider.rouge,
                          ),
                        ),
                      )
                    else
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BoardCarousel(),
                          SizedBox(height: 45),
                          RecentNotificationsList(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
        );
      },
    );
  }
}
