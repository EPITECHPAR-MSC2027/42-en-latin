import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
import 'package:fluter/widgets/board_carousel.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
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
    Future<void>.microtask(() async => _loadData());
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Mes Boards'),
        actions: <Widget>[
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
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Prêt à travailler ?',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading) 
                  const Center(child: CircularProgressIndicator()) 
                else if (_errorMessage != null)
                  Center(child: Text('Erreur: $_errorMessage'))
                else
                  const BoardCarousel(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
