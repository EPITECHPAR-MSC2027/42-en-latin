import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWorkspaces();
  }

  void _initializeWorkspaces() {
    Future.microtask(() async {
      await _loadWorkspaces();
    });
  }

  Future<void> _loadWorkspaces() async {
    try {
      await Provider.of<WorkspaceProvider>(context, listen: false).fetchWorkspaces();
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
    body: Stack(
      clipBehavior: Clip.none, // Permet à l’image de dépasser
      children: [
        Column(
          children: [
            // AppBar avec titre et icône
            AppBar(
              backgroundColor: const Color(0xFFC0CDA9),
              centerTitle: true,
              elevation: 0,
              
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your WorkSpace',
                    style: GoogleFonts.itim(
                      fontSize: 30, 
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF889596),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Espace pour éviter que le contenu touche l’image
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text('Erreur: $_errorMessage'))
                      : Consumer<WorkspaceProvider>(
                          builder: (context, provider, child) {
                            final workspaces = provider.workspaces;
                            if (workspaces.isEmpty) {
                              return const Center(child: Text('Aucun workspace trouvé.'));
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: workspaces.length,
                              itemBuilder: (context, index) {
                                final workspace = workspaces[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      workspace.displayName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(workspace.desc ?? 'Aucune description'),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BoardsScreen(
                                            workspaceId: workspace.id,
                                            workspaceName: workspace.displayName,
                                          ),
                                        ),
                                      );
                                      _initializeWorkspaces(); // Recharger après retour
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),

        // Image placée en dehors de l'AppBar
        Positioned(
          left: -40,
          top: 0, // Fait dépasser sous l'AppBar
          child: Image.asset(
            'documentation/pic.png',
            height: 120, // Agrandit l’image
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),

    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 20),
      child: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const ManageWorkspacesScreen(),
            ),
          );
          setState(_initializeWorkspaces);
        },
        backgroundColor: const Color(0xFFC0CDA9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.settings, color: Color(0xFFD97C83)),
      ),
    ),

    bottomNavigationBar: const BottomNavBar(),
  );
}


}
