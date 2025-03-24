import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **Écran de gestion des workspaces**
class ManageWorkspacesScreen extends StatefulWidget {
  /// **Constructeur de ManageWorkspacesScreen**
  const ManageWorkspacesScreen({super.key});

  @override
  ManageWorkspacesScreenState createState() => ManageWorkspacesScreenState();
}

/// **État de ManageWorkspacesScreen**
class ManageWorkspacesScreenState extends State<ManageWorkspacesScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async => _loadWorkspaces());
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
      appBar: AppBar(title: const Text('Mes Workspaces')),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await provider.removeWorkspace(workspace.id);
                            },
                          ),
                          onTap: () async {
                            await _editWorkspaceDialog(context, workspace, provider);
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

  /// **Affiche le dialogue pour créer un workspace**
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
            TextField(decoration: const InputDecoration(labelText: 'Nom'), onChanged: (String val) => name = val),
            TextField(decoration: const InputDecoration(labelText: 'Nom affiché'), onChanged: (String val) => displayName = val),
            TextField(decoration: const InputDecoration(labelText: 'Description'), onChanged: (String val) => desc = val),
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

  /// **Affiche le dialogue pour modifier un workspace**
  Future<void> _editWorkspaceDialog(BuildContext context, Workspace workspace, WorkspaceProvider provider) async {
    String newDisplayName = workspace.displayName;
    String newDesc = workspace.desc ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Modifier Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: newDisplayName),
              decoration: const InputDecoration(labelText: 'Nom affiché'),
              onChanged: (String val) => newDisplayName = val,
            ),
            TextField(
              controller: TextEditingController(text: newDesc),
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (String val) => newDesc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.editWorkspace(workspace.id, newDisplayName, newDesc);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
