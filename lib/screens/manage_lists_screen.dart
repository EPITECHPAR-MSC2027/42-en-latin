import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';
import '../models/list.dart';

class ManageListsScreen extends StatelessWidget {
  final String boardId;
  final String boardName;

  const ManageListsScreen({super.key, required this.boardId, required this.boardName});

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Gérer les listes de $boardName')),
      body: FutureBuilder(
        future: listProvider.fetchListsByBoard(boardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<ListProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.lists.length,
                itemBuilder: (context, index) {
                  final ListModel list = provider.lists[index];

                  return ListTile(
                    title: Text(list.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editListDialog(context, list, provider),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.removeList(list.id),
                        ),
                      ],
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
        onPressed: () => _addListDialog(context, listProvider),
      ),
    );
  }

  void _addListDialog(BuildContext context, ListProvider provider) {
    String name = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une Liste'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Nom'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              provider.addList(boardId, name);
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _editListDialog(BuildContext context, ListModel list, ListProvider provider) {
    String newName = list.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la Liste'),
        content: TextField(
          controller: TextEditingController(text: newName),
          decoration: const InputDecoration(labelText: 'Nom'),
          onChanged: (val) => newName = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              provider.editList(list.id, newName);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
