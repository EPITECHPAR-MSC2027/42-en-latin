import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// **Écran des Workspaces**
class WorkspacesScreen extends StatefulWidget {
  /// **Constructeur**
  const WorkspacesScreen({super.key});

  @override
  WorkspacesScreenState createState() => WorkspacesScreenState();
}

/// **État de `WorkspacesScreen`**
class WorkspacesScreenState extends State<WorkspacesScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async => _loadWorkspaces());
  }

  /// **Charge les Workspaces**
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
        backgroundColor: const Color(0xFFC0CDA9),
        title: const Text(
          'Mes Workspaces',
          style: TextStyle(
            fontFamily: 'Itim',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF889596),
          ),
        ),
        
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
                                builder: (BuildContext context) => BoardsScreen(
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async => _addWorkspaceDialog(context, Provider.of<WorkspaceProvider>(context, listen: false)),
      ),
    );
  }

  /// **Ajoute un Workspace**
  Future<void> _addWorkspaceDialog(BuildContext context, WorkspaceProvider provider) async {
    String name = '';
    String displayName = '';
    String desc = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer un Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (String val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Nom affiché'),
              onChanged: (String val) => displayName = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (String val) => desc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.addWorkspace(name, displayName, desc);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
