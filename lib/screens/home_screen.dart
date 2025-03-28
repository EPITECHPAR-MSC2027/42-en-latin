import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/screens/ManageWorkspacesScreen.dart';
import 'package:fluter/widgets/board_carousel.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:fluter/widgets/notifications_dropdown.dart';
import 'package:fluter/widgets/recent_notifications_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// **Écran d'accueil**
class HomeScreen extends StatefulWidget {
  /// **Constructeur de HomeScreen**
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

/// **État de HomeScreen**
class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await _loadData();
      // Charger les notifications au démarrage
      // ignore: use_build_context_synchronously
      await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  /// **Charge les données nécessaires**
  Future<void> _loadData() async {
    try {
      // Charger les boards pour le carousel
      await Provider.of<BoardsProvider>(context, listen: false).fetchBoards();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3),
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color(0xFFC0CCC9),
        actions: <Widget>[
          const NotificationsDropdown(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Workspaces',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ManageWorkspacesScreen(),
                ),
              );
              // Recharger les boards après la gestion des workspaces
              await _loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Welcome Back',
                    style: GoogleFonts.itim(
                      fontSize: 44,
                      color: const Color(0xFFC27C88),
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
                      color: const Color(0xFF314A43),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Center(child: Text('Erreur: $_errorMessage'))
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
  }
}
