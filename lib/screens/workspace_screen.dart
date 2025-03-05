import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
import 'package:flutter/material.dart';
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
    Future.microtask(() async => _loadWorkspaces());
  }

  /// **Charge les workspaces**
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
      appBar: AppBar(
        title: const Text('Mes Workspaces'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Workspaces',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageWorkspacesScreen()),
              );
              // Après le retour de la gestion des workspaces, nous rechargeons les données
              setState(_initializeWorkspaces);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<WorkspaceProvider>(
                  builder: (BuildContext context, WorkspaceProvider provider, Widget? child) {
                    final workspaces = provider.workspaces;
                    if (workspaces.isEmpty) {
                      return const Center(child: Text('Aucun workspace trouvé.'));
                    }

                    return ListView.builder(
                      itemCount: workspaces.length,
                      itemBuilder: (BuildContext context, int index) {
                        final workspace = workspaces[index];
                        return ListTile(
                          title: Text(workspace.displayName),
                          subtitle: Text(workspace.desc ?? 'Aucune description'),
                          trailing: const Icon(Icons.arrow_forward),
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
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
