import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../services/trello_service.dart';
import 'workspace_screen.dart'; // Import de l'écran Workspaces

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trelloService = Provider.of<TrelloService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trello Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspaces),
            tooltip: 'Gérer les Workspaces',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkspaceScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Board>>(
        future: trelloService.getBoards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun board trouvé'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Board board = snapshot.data![index];
                return ListTile(
                  title: Text(board.name),
                  subtitle: Text(board.desc),
                  onTap: () {},
                );
              },
            );
          }
        },
      ),
    );
  }
}
