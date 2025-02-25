import 'package:fluter/models/board.dart';
import 'package:fluter/providers/broad_providers.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageBoardsScreen extends StatelessWidget {

  const ManageBoardsScreen({super.key, required this.workspaceId, required this.workspaceName});
  final String workspaceId;
  final String workspaceName;

  @override
  Widget build(BuildContext context) {
    final BoardsProvider boardsProvider = Provider.of<BoardsProvider>(context, listen: false);
    final WorkspaceProvider workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Boards de $workspaceName')),
      body: FutureBuilder(
        future: workspaceProvider.fetchBoardsByWorkspace(workspaceId), // Récupère les boards
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await boardsProvider.removeBoard(board.id); // Supprime le board
                        await workspaceProvider.fetchBoardsByWorkspace(workspaceId); // Rafraîchit la liste
                      },
                    ),
                    onTap: () {
                      _editBoardDialog(context, board, boardsProvider, workspaceProvider);
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
        onPressed: () => _addBoardDialog(context, boardsProvider, workspaceProvider),
      ),
    );
  }

  void _addBoardDialog(BuildContext context, BoardsProvider boardsProvider, WorkspaceProvider workspaceProvider) {
    String name = '';
    String desc = '';

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer un Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Nom du board'),
              onChanged: (String val) => name = val,
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
              await boardsProvider.addBoard(workspaceId, name, desc); // Ajoute le board
              await workspaceProvider.fetchBoardsByWorkspace(workspaceId); // Rafraîchit la liste
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
void _editBoardDialog(BuildContext context, Board board, BoardsProvider boardsProvider, WorkspaceProvider workspaceProvider) {
  TextEditingController nameController = TextEditingController(text: board.name);
  TextEditingController descController = TextEditingController(text: board.desc ?? '');

  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Modifier Board'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nom du board'),
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            await boardsProvider.editBoard(board.id, nameController.text, descController.text);
            await workspaceProvider.fetchBoardsByWorkspace(workspaceId); // Rafraîchir les boards du workspace
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
