import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../services/trello_service.dart';

/// The home screen of the application, displaying a list of Trello boards.
///
/// This screen fetches the list of boards from the Trello API using the [TrelloService]
/// and displays them in a list. It also handles loading, errors, and empty states.
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trelloService = Provider.of<TrelloService>(context);
void showAddBoardDialog(BuildContext context, TrelloService trelloService) {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Créer un Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nom du board'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              String desc = descController.text.trim();

              if (name.isNotEmpty) {
                await trelloService.createBoard(name, desc);
                Navigator.of(context).pop(); // Ferme la pop-up
                (context as Element).reassemble(); // Rafraîchir la liste
              }
            },
            child: Text('Créer'),
          ),
        ],
      );
    },
  );
}

    

    return Scaffold(
      appBar: AppBar(
        title: Text('Trello Boards'),
         actions: [
        IconButton(
         icon: Icon(Icons.add),
            onPressed: () {
              showAddBoardDialog(context,trelloService); // Affiche la boîte de dialogue
            },
          ),
  ],
      ),
      body: FutureBuilder<List<Board>>(
        future: trelloService.getBoards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No boards found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Board board = snapshot.data![index];
                return ListTile(
                  title: Text(board.name),
                  subtitle: Text(board.desc),
                  onTap: () {
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}