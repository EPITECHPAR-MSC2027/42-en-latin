import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../models/board.dart';
import 'lists_screen.dart';

class BoardsScreen extends StatelessWidget {
  final String workspaceId;
  final String workspaceName;

  const BoardsScreen({super.key, required this.workspaceId, required this.workspaceName});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Boards de $workspaceName')),
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
                    subtitle: Text(board.desc.isNotEmpty ? board.desc : 'Pas de description'),
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
