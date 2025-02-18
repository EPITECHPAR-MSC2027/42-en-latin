import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../models/workspace.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Workspaces')),
      body: FutureBuilder(
        future: workspaceProvider.fetchWorkspaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<WorkspaceProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.workspaces.length,
                itemBuilder: (context, index) {
                  final Workspace workspace = provider.workspaces[index];

                  return ListTile(
                    title: Text(workspace.displayName),
                    subtitle: Text(workspace.desc ?? 'Aucune description'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.removeWorkspace(workspace.id),
                    ),
                    onTap: () {
                      _editWorkspaceDialog(context, workspace, provider);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addWorkspaceDialog(context, workspaceProvider),
      ),
    );
  }

  void _addWorkspaceDialog(BuildContext context, WorkspaceProvider provider) {
    String name = '', displayName = '', desc = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nom'), onChanged: (val) => name = val),
            TextField(decoration: const InputDecoration(labelText: 'Nom affiché'), onChanged: (val) => displayName = val),
            TextField(decoration: const InputDecoration(labelText: 'Description'), onChanged: (val) => desc = val),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              provider.addWorkspace(name, displayName, desc);
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _editWorkspaceDialog(BuildContext context, Workspace workspace, WorkspaceProvider provider) {
    String newDisplayName = workspace.displayName;
    String newDesc = workspace.desc ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: newDisplayName),
              decoration: const InputDecoration(labelText: 'Nom affiché'),
              onChanged: (val) => newDisplayName = val,
            ),
            TextField(
              controller: TextEditingController(text: newDesc),
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => newDesc = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              provider.editWorkspace(workspace.id, newDisplayName, newDesc);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
