import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
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
    Future<void>.microtask(() async => _loadWorkspaces());
  }

  Future<void> _loadWorkspaces() async {
    try {
      await Provider.of<WorkspaceProvider>(
        context,
        listen: false,
      ).fetchWorkspaces();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Workspaces'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Workspaces',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (BuildContext context) => const ManageWorkspacesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<WorkspaceProvider>(
                builder: (
                  BuildContext context,
                  WorkspaceProvider provider,
                  Widget? child,
                ) {
                  if (provider.workspaces.isEmpty) {
                    return const Center(child: Text('Aucun workspace trouvé.'));
                  }

                  return ListView.builder(
                    itemCount: provider.workspaces.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Workspace workspace = provider.workspaces[index];

                      return ListTile(
                        title: Text(workspace.displayName),
                        subtitle: Text(workspace.desc ?? 'Aucune description'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) => BoardsScreen(
                                    workspaceId: workspace.id,
                                    workspaceName: workspace.displayName,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
