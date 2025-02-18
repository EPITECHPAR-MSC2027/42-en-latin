import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../models/workspace.dart';
import 'boards_screen.dart';
import 'manage_workspaces_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Workspaces'),
        actions: [
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
              if (provider.workspaces.isEmpty) {
                return const Center(child: Text('Aucun workspace trouvé.'));
              }

              return ListView.builder(
                itemCount: provider.workspaces.length,
                itemBuilder: (context, index) {
                  final Workspace workspace = provider.workspaces[index];

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
