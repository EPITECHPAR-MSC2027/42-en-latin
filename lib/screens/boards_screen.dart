import 'package:fluter/models/board.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/screens/manage_BoardsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoardsScreen extends StatelessWidget {
  final String workspaceId;
  final String workspaceName;

  const BoardsScreen({super.key, required this.workspaceId, required this.workspaceName});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Boards de $workspaceName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Board',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                      builder: (context) => ManageBoardsScreen(
                       workspaceId: workspaceId,
                       workspaceName: workspaceName,
                ),
              ),
              );
            },
          ),
        ],
      
      
      
      ),
      body: FutureBuilder(
        future: workspaceProvider.fetchBoardsByWorkspace(workspaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<WorkspaceProvider>(
            builder: (context, provider, child) {
              if (provider.workspaceBoards.isEmpty) {
                return const Center(child: Text('Aucun board trouvé pour ce workspace.'));
              }

              return ListView.builder(
                itemCount: provider.workspaceBoards.length,
                itemBuilder: (context, index) {
                  final Board board = provider.workspaceBoards[index];
                  return ListTile(
                    title: Text(board.name),
                    subtitle: Text(board.desc),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListsScreen(
                            boardId: board.id,
                            boardName: board.name,
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