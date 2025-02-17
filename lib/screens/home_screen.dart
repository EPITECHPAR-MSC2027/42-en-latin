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

    return Scaffold(
      appBar: AppBar(
        title: Text('Trello Boards'),
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