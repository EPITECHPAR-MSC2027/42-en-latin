import 'package:fluter/models/workspace.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/screens/manage_workspaces_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkspaceProvider workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Workspaces'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Workspaces',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageWorkspacesScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Workspace>>(
        future: workspaceProvider.fetchWorkspaces(),
        builder: (BuildContext context, AsyncSnapshot<List<Workspace>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun workspace trouvé.'));
          }

          return Consumer<WorkspaceProvider>(
            builder: (BuildContext context, WorkspaceProvider provider, Widget? child) {
              final List<Workspace> workspaces = provider.workspaces;

              return ListView.builder(
                itemCount: workspaces.length,
                itemBuilder: (BuildContext context, int index) {
                  final Workspace workspace = workspaces[index];

                  return ListTile(
                    title: Text(workspace.displayName),
                    subtitle: Text(workspace.desc ?? 'Aucune description'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
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
          );
        },
      ),
    );
  }
}