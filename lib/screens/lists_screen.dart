import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';
import '../models/list.dart';

class ListsScreen extends StatelessWidget {
  final String boardId;
  final String boardName;

  const ListsScreen({super.key, required this.boardId, required this.boardName});

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Listes de $boardName')),
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
              if (provider.lists.isEmpty) {
                return const Center(child: Text('Aucune liste trouvée pour ce board.'));
              }

              return ListView.builder(
                itemCount: provider.lists.length,
                itemBuilder: (context, index) {
                  final ListModel list = provider.lists[index];

                  return ListTile(
                    title: Text(list.name),
                    onTap: () {
                      // Ici, on pourra afficher les cartes d'une liste plus tard
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
