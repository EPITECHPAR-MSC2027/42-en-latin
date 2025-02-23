import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageWorkspacesScreen extends StatelessWidget {
  const ManageWorkspacesScreen({super.key});

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
                      onPressed: () async => provider.removeWorkspace(workspace.id),
                    ),
                    onTap: () async {
                      await _editWorkspaceDialog(context, workspace, provider);
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
        onPressed: () async => _addWorkspaceDialog(context, workspaceProvider),
      ),
    );
  }

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

  Future<void> _editWorkspaceDialog(BuildContext context, Workspace workspace, WorkspaceProvider provider) async {
    String newDisplayName = workspace.displayName;
    String newDesc = workspace.desc ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Modifier Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.editWorkspace(workspace.id, newDisplayName, newDesc);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
