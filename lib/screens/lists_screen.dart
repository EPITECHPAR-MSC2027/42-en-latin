import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/screens/cards_screen.dart';
import 'package:fluter/screens/manage_lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListsScreen extends StatelessWidget {

  const ListsScreen({super.key, required this.boardId, required this.boardName});
  final String boardId;
  final String boardName;

  @override
  Widget build(BuildContext context) {
    final ListProvider listProvider = Provider.of<ListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Listes de $boardName'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Listes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => ManageListsScreen(boardId: boardId, boardName: boardName)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: listProvider.fetchListsByBoard(boardId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<ListProvider>(
            builder: (BuildContext context, ListProvider provider, Widget? child) {
              if (provider.lists.isEmpty) {
                return const Center(child: Text('Aucune liste trouvée pour ce board.'));
              }

              return ListView.builder(
                itemCount: provider.lists.length,
                itemBuilder: (BuildContext context, int index) {
                  final ListModel list = provider.lists[index];

                  return ListTile(
                    title: Text(list.name),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // 🔹 Ouvrir `CardsScreen` lorsqu’on clique sur une List
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CardsScreen(
                            listId: list.id,
                            listName: list.name,
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