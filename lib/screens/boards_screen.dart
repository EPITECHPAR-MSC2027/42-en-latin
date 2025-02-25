import 'package:fluter/models/board.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/screens/manage_BoardsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoardsScreen extends StatelessWidget {

  const BoardsScreen({super.key, required this.workspaceId, required this.workspaceName});
  final String workspaceId;
  final String workspaceName;

  @override
  Widget build(BuildContext context) {
    final WorkspaceProvider workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Boards de $workspaceName'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Board',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                      builder: (BuildContext context) => ManageBoardsScreen(
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
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<WorkspaceProvider>(
            builder: (BuildContext context, WorkspaceProvider provider, Widget? child) {
              if (provider.workspaceBoards.isEmpty) {
                return const Center(child: Text('Aucun board trouvé pour ce workspace.'));
              }

              return ListView.builder(
                itemCount: provider.workspaceBoards.length,
                itemBuilder: (BuildContext context, int index) {
                  final Board board = provider.workspaceBoards[index];
                  return ListTile(
                    title: Text(board.name),
                    subtitle: Text(board.desc),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ListsScreen(
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